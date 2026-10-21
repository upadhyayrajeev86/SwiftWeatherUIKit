//
//  WeatherViewModel.swift
//  SwiftWeatherUIKit
//
//  Created by Rajeev  Upadhyay on 21/10/26.
//


import Foundation

@MainActor
final class WeatherViewModel {

    enum State {
        case idle
        case loading
        case loaded(CurrentWeather)
        case failed(String)
    }

    private let weatherService: WeatherServiceProtocol

    private(set) var state: State = .idle {
        didSet {
            onStateChange?(state)
        }
    }

    var onStateChange: ((State) -> Void)?

    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    func loadWeather(
        latitude: Double,
        longitude: Double
    ) async {
        state = .loading

        do {
            let weather = try await weatherService.fetchWeather(
                latitude: latitude,
                longitude: longitude
            )
            state = .loaded(weather)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
