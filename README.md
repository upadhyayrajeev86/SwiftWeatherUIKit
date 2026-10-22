# SwiftWeatherUIKit

A UIKit-based weather application built with Swift, demonstrating MVVM architecture, asynchronous networking, dependency injection, and unit testing.

Designed as a portfolio project to demonstrate production-minded iOS engineering practices.

## Features

- Fetches live weather data for New Delhi.
- Displays temperature, weather conditions, feels-like temperature, humidity, wind speed, and precipitation.
- Uses async/await for asynchronous networking.
- Supports loading, success, and error states.
- Provides a refresh button to fetch the latest weather.
- Uses programmatic UIKit layouts and Auto Layout.
- Includes unit tests for ViewModel behavior and network-service responses.

## Tech Stack

- **Language:** Swift
- **UI:** UIKit, Auto Layout
- **Architecture:** Model–View–ViewModel (MVVM)
- **Networking:** URLSession, async/await
- **Data Parsing:** Codable / Decodable
- **Dependency Injection:** Protocol-based service abstraction
- **Testing:** XCTest, mocked services, custom URLProtocol
- **API:** Open-Meteo Forecast API

## Architecture

The application separates presentation, business logic, and networking responsibilities.

```text
ViewController
      |
      v
WeatherViewModel
      |
      v
WeatherServiceProtocol
      |
      v
URLSessionWeatherService
      |
      v
Open-Meteo API
```

### Responsibilities

**ViewController**
- Builds the UIKit interface programmatically.
- Observes ViewModel state changes.
- Renders weather information, loading indicators, and errors.
- Handles user interaction such as refreshing the weather.

**WeatherViewModel**
- Manages idle, loading, loaded, and failed states.
- Coordinates weather fetching.
- Exposes state changes to the view.
- Depends on a protocol rather than a concrete networking implementation.

**WeatherServiceProtocol**
- Defines the contract for retrieving weather data.
- Allows the real service to be replaced with a mock during testing.

**URLSessionWeatherService**
- Constructs the API request.
- Performs asynchronous HTTP networking.
- Validates HTTP status codes.
- Decodes the JSON response into Swift models.

## Project Structure

```text
SwiftWeatherUIKit/
├── AppDelegate.swift
├── SceneDelegate.swift
├── ViewController.swift
├── Models/
│   └── Weather.swift
├── Services/
│   └── WeatherService.swift
├── ViewModels/
│   └── WeatherViewModel.swift
└── Base.lproj/
    ├── Main.storyboard
    └── LaunchScreen.storyboard

SwiftWeatherUIKitTests/
└── SwiftWeatherUIKitTests.swift
```

## API

This project uses the Open-Meteo Forecast API:

https://api.open-meteo.com/v1/forecast

The application requests current weather data for New Delhi using latitude and longitude coordinates.

No API key is required for this basic example. Refer to the provider's documentation for usage conditions and available features:

https://open-meteo.com/en/docs

## Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/upadhyayrajeev86/SwiftWeatherUIKit.git
   ```

2. Open `SwiftWeatherUIKit.xcodeproj` in Xcode.
3. Select the `SwiftWeatherUIKit` scheme and an iOS simulator.
4. Build and run the application.

An active internet connection is required to fetch live weather data.

## Testing

The project includes five unit tests covering:

- Successful weather loading in the ViewModel.
- Failure handling in the ViewModel.
- Loading-to-success state transitions.
- Successful HTTP response and JSON decoding.
- HTTP error handling.

The network-service tests use a custom `URLProtocol` to simulate HTTP responses without making real network requests.

Run the test suite in Xcode using **Product → Test** or the keyboard shortcut `⌘U`.

## Engineering Principles Demonstrated

- Separation of concerns
- Protocol-oriented design
- Dependency injection
- Asynchronous programming with Swift concurrency
- HTTP response validation
- Testable networking architecture
- Deterministic unit testing with mocked dependencies

## Potential Enhancements

- Location search and Core Location integration
- Weather icons and improved visual design
- Forecasts for upcoming days
- Retry handling and more structured error presentation
- Accessibility improvements
- Additional edge-case and UI tests
- Continuous integration with GitHub Actions

## License

This project is intended for learning, demonstration, and portfolio purposes. Add an explicit open-source license if you plan to permit reuse by others.
