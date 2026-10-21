//
//  SwiftWeatherUIKitTests.swift
//  SwiftWeatherUIKitTests
//
//  Created by Rajeev  Upadhyay on 20/10/26.
//


import XCTest
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
}
