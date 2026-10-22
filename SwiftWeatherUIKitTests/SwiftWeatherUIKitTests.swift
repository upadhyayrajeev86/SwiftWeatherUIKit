//
//  SwiftWeatherUIKitTests.swift
//  SwiftWeatherUIKitTests
//
//  Created by Rajeev  Upadhyay on 20/10/26.
//


import XCTest
import Foundation
@testable import SwiftWeatherUIKit

private struct MockWeatherService: WeatherServiceProtocol {

    let result: Result<CurrentWeather, Error>

    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> CurrentWeather {
        try result.get()
    }
}

@MainActor
final class SwiftWeatherUIKitTests: XCTestCase {

    func testLoadWeatherSuccess() async {
        // Arrange
        let expectedWeather = CurrentWeather(
            temperature2m: 28.0,
            relativeHumidity2m: 65,
            apparentTemperature: 30.0,
            isDay: 1,
            precipitation: 0.0,
            weatherCode: 2,
            windSpeed10m: 12.0
        )

        let service = MockWeatherService(
            result: .success(expectedWeather)
        )

        let viewModel = WeatherViewModel(
            weatherService: service
        )

        var receivedWeather: CurrentWeather?

        viewModel.onStateChange = { state in
            if case .loaded(let weather) = state {
                receivedWeather = weather
            }
        }

        // Act
        await viewModel.loadWeather(
            latitude: 28.6139,
            longitude: 77.2090
        )

        // Assert
        XCTAssertEqual(
            receivedWeather?.temperature2m,
            expectedWeather.temperature2m
        )

        XCTAssertEqual(
            receivedWeather?.relativeHumidity2m,
            expectedWeather.relativeHumidity2m
        )
    }

    func testLoadWeatherFailure() async {
        // Arrange
        let expectedError = NSError(
            domain: "WeatherTests",
            code: 500,
            userInfo: [
                NSLocalizedDescriptionKey: "Test network error"
            ]
        )

        let service = MockWeatherService(
            result: .failure(expectedError)
        )

        let viewModel = WeatherViewModel(
            weatherService: service
        )

        var receivedError: String?

        viewModel.onStateChange = { state in
            if case .failed(let message) = state {
                receivedError = message
            }
        }

        // Act
        await viewModel.loadWeather(
            latitude: 28.6139,
            longitude: 77.2090
        )

        // Assert
        XCTAssertEqual(
            receivedError,
            expectedError.localizedDescription
        )
    }
    
    
    func testLoadWeatherEmitsLoadingThenLoaded() async {
        let weather = CurrentWeather(
            temperature2m: 28.0,
            relativeHumidity2m: 65,
            apparentTemperature: 30.0,
            isDay: 1,
            precipitation: 0.0,
            weatherCode: 2,
            windSpeed10m: 12.0
        )

        let service = MockWeatherService(
            result: .success(weather)
        )

        let viewModel = WeatherViewModel(
            weatherService: service
        )

        var receivedStates: [String] = []

        viewModel.onStateChange = { state in
            switch state {
            case .idle:
                receivedStates.append("idle")
            case .loading:
                receivedStates.append("loading")
            case .loaded:
                receivedStates.append("loaded")
            case .failed:
                receivedStates.append("failed")
            }
        }

        await viewModel.loadWeather(
            latitude: 28.6139,
            longitude: 77.2090
        )

        XCTAssertEqual(
            receivedStates,
            ["loading", "loaded"]
        )
    }
    
    
    func testWeatherServiceDecodesSuccessfulResponse() async throws {
        let json = """
        {
            "current": {
                "temperature_2m": 28.0,
                "relative_humidity_2m": 65,
                "apparent_temperature": 30.0,
                "is_day": 1,
                "precipitation": 0.0,
                "weather_code": 2,
                "wind_speed_10m": 12.0
            }
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!

            return (response, json)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let session = URLSession(configuration: configuration)
        let service = URLSessionWeatherService(session: session)

        let weather = try await service.fetchWeather(
            latitude: 28.6139,
            longitude: 77.2090
        )

        XCTAssertEqual(weather.temperature2m, 28.0)
        XCTAssertEqual(weather.relativeHumidity2m, 65)
        XCTAssertEqual(weather.weatherCode, 2)

        session.invalidateAndCancel()
        MockURLProtocol.requestHandler = nil
    }


    func testWeatherServiceThrowsForHTTPError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!

            return (response, Data())
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        let session = URLSession(configuration: configuration)
        let service = URLSessionWeatherService(session: session)

        do {
            _ = try await service.fetchWeather(
                latitude: 28.6139,
                longitude: 77.2090
            )
            XCTFail("Expected an HTTP error")
        } catch let error as WeatherServiceError {
            if case .httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("Expected httpError, received \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        session.invalidateAndCancel()
        MockURLProtocol.requestHandler = nil
    }

}


private final class MockURLProtocol: URLProtocol {

    static var requestHandler:
        ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            fatalError("MockURLProtocol requestHandler is not configured")
        }

        do {
            let (response, data) = try handler(request)

            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

