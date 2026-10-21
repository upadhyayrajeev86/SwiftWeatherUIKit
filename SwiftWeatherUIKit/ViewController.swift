//
//  ViewController.swift
//  SwiftWeatherUIKit
//
//  Created by Rajeev  Upadhyay on 20/10/26.
//



import UIKit

@MainActor
final class ViewController: UIViewController {

    private let viewModel = WeatherViewModel(
        weatherService: URLSessionWeatherService()
    )

    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    private let humidityLabel = UILabel()
    private let windLabel = UILabel()
    private let precipitationLabel = UILabel()
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let refreshButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Swift Weather"

        configureViews()
        configureLayout()
        bindViewModel()

        Task {
            await loadWeather()
        }
    }

    private func configureViews() {
        cityLabel.text = "New Delhi"
        cityLabel.font = .systemFont(ofSize: 28, weight: .bold)
        cityLabel.textAlignment = .center

        temperatureLabel.text = "--°"
        temperatureLabel.font = .systemFont(ofSize: 64, weight: .light)
        temperatureLabel.textAlignment = .center

        conditionLabel.text = "Current weather"
        conditionLabel.font = .systemFont(ofSize: 18)
        conditionLabel.textColor = .secondaryLabel
        conditionLabel.textAlignment = .center

        feelsLikeLabel.text = "Feels like: --°"
        humidityLabel.text = "Humidity: --%"
        windLabel.text = "Wind: -- km/h"
        precipitationLabel.text = "Precipitation: -- mm"

        [
            feelsLikeLabel,
            humidityLabel,
            windLabel,
            precipitationLabel
        ].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        statusLabel.text = "Fetching weather..."
        statusLabel.textColor = .secondaryLabel
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        activityIndicator.hidesWhenStopped = true

        refreshButton.setTitle("Refresh Weather", for: .normal)
        refreshButton.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .semibold
        )
        refreshButton.addTarget(
            self,
            action: #selector(refreshTapped),
            for: .touchUpInside
        )

        [
            cityLabel,
            temperatureLabel,
            conditionLabel,
            feelsLikeLabel,
            humidityLabel,
            windLabel,
            precipitationLabel,
            statusLabel,
            activityIndicator,
            refreshButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func configureLayout() {
        let metricsStack = UIStackView(arrangedSubviews: [
            feelsLikeLabel,
            humidityLabel,
            windLabel,
            precipitationLabel
        ])
        metricsStack.axis = .vertical
        metricsStack.spacing = 18
        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metricsStack)

        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 32
            ),
            cityLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            cityLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            temperatureLabel.topAnchor.constraint(
                equalTo: cityLabel.bottomAnchor,
                constant: 20
            ),
            temperatureLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            conditionLabel.topAnchor.constraint(
                equalTo: temperatureLabel.bottomAnchor,
                constant: 4
            ),
            conditionLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 20
            ),
            conditionLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -20
            ),

            activityIndicator.topAnchor.constraint(
                equalTo: conditionLabel.bottomAnchor,
                constant: 20
            ),
            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            statusLabel.topAnchor.constraint(
                equalTo: activityIndicator.bottomAnchor,
                constant: 12
            ),
            statusLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            statusLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            metricsStack.topAnchor.constraint(
                equalTo: statusLabel.bottomAnchor,
                constant: 28
            ),
            metricsStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            metricsStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            ),

            refreshButton.topAnchor.constraint(
                equalTo: metricsStack.bottomAnchor,
                constant: 32
            ),
            refreshButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            refreshButton.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            )
        ])
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    private func loadWeather() async {
        await viewModel.loadWeather(
            latitude: 28.6139,
            longitude: 77.2090
        )
    }

    @objc private func refreshTapped() {
        Task {
            await loadWeather()
        }
    }

    private func render(_ state: WeatherViewModel.State) {
        switch state {
        case .idle:
            statusLabel.text = "Ready to fetch weather."
            activityIndicator.stopAnimating()

        case .loading:
            statusLabel.text = "Fetching latest weather..."
            activityIndicator.startAnimating()
            refreshButton.isEnabled = false

        case .loaded(let weather):
            activityIndicator.stopAnimating()
            refreshButton.isEnabled = true

            temperatureLabel.text =
                "\(Int(weather.temperature2m.rounded()))°C"

            conditionLabel.text = conditionDescription(
                for: weather.weatherCode
            )

            feelsLikeLabel.text =
                "Feels like: \(Int(weather.apparentTemperature.rounded()))°C"

            humidityLabel.text =
                "Humidity: \(weather.relativeHumidity2m)%"

            windLabel.text =
                "Wind: \(Int(weather.windSpeed10m.rounded())) km/h"

            precipitationLabel.text =
                "Precipitation: \(weather.precipitation) mm"

            statusLabel.text = weather.isDay == 1
                ? "Daytime conditions"
                : "Nighttime conditions"

        case .failed(let message):
            activityIndicator.stopAnimating()
            refreshButton.isEnabled = true
            statusLabel.text = "Unable to load weather: \(message)"
        }
    }

    private func conditionDescription(for code: Int) -> String {
        switch code {
        case 0:
            return "Clear sky"
        case 1:
            return "Mainly clear"
        case 2:
            return "Partly cloudy"
        case 3:
            return "Overcast"
        case 45, 48:
            return "Foggy"
        case 51, 53, 55:
            return "Drizzle"
        case 56, 57:
            return "Freezing drizzle"
        case 61, 63, 65:
            return "Rain"
        case 66, 67:
            return "Freezing rain"
        case 71, 73, 75, 77:
            return "Snow"
        case 80, 81, 82:
            return "Rain showers"
        case 85, 86:
            return "Snow showers"
        case 95:
            return "Thunderstorm"
        case 96, 99:
            return "Thunderstorm with hail"
        default:
            return "Unknown conditions"
        }
    }
}


