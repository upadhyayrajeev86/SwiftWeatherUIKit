//
//  Weather.swift
//  SwiftWeatherUIKit
//
//  Created by Rajeev  Upadhyay on 21/10/26.
//


import Foundation

struct WeatherResponse: Decodable {
    let current: CurrentWeather

    enum CodingKeys: String, CodingKey {
        case current
    }
}

struct CurrentWeather: Decodable {
    let temperature2m: Double
    let relativeHumidity2m: Int
    let apparentTemperature: Double
    let isDay: Int
    let precipitation: Double
    let weatherCode: Int
    let windSpeed10m: Double

    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case isDay = "is_day"
        case precipitation
        case weatherCode = "weather_code"
        case windSpeed10m = "wind_speed_10m"
    }
}
