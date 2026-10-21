//
//  WeatherService.swift
//  SwiftWeatherUIKit
//
//  Created by Rajeev  Upadhyay on 21/10/26.
//


import Foundation

protocol WeatherServiceProtocol {
    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> CurrentWeather
}

enum WeatherServiceError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
}

final class URLSessionWeatherService: WeatherServiceProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> CurrentWeather {

        var components = URLComponents(
            string: "https://api.open-meteo.com/v1/forecast"
        )

        components?.queryItems = [
            URLQueryItem(
                name: "latitude",
                value: String(latitude)
            ),
            URLQueryItem(
                name: "longitude",
                value: String(longitude)
            ),
            URLQueryItem(
                name: "current",
                value: """
                temperature_2m,relative_humidity_2m,\
                apparent_temperature,is_day,precipitation,\
                weather_code,wind_speed_10m
                """
            )
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherServiceError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        let weatherResponse = try JSONDecoder().decode(
            WeatherResponse.self,
            from: data
        )

        return weatherResponse.current
    }
}
