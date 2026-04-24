//
//  WeatherRepositoryTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/5/25.
//

import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct WeatherRepositoryTests {

	var mockNetwork: MockNetworkManager
	var mockConfig: MockWeatherConfiguration

	init() {
		self.mockNetwork = MockNetworkManager()
		self.mockConfig = MockWeatherConfiguration()
	}

	@Test
	func 네트워크응답이정상적일때_fetchCurrentWeather하면_Weather도메인엔티티로잘변환되는지() async throws {
		// Given
		let dummyDTO = WeatherResponseDTO(
			weather: [.init(id: 800, main: "Clear", description: "sunny", icon: "01d")],
			main: .init(temp: 20.0, feelsLike: 20.0, tempMin: 10.0, tempMax: 30.0, pressure: 1000, humidity: 50),
			name: "Test City"
		)
		mockNetwork.resultDTO = dummyDTO

		let repository = WeatherRepositoryImpl(
			networkManager: mockNetwork,
			configuration: mockConfig
		)

		// When
		let weather = try await repository.fetchCurrentWeather(latitude: 37.5, longitude: 127.0)

		// Then
		#expect(weather.cityName == "Test City")
		#expect(weather.temperature == 20.0)
		#expect(weather.condition == .clear)
	}

	@Test
	mutating func APIKey가비어있을때_fetchCurrentWeather하면_configurationError를던지는지() async {
		// Given
		mockConfig.apiKey = ""
		let repository = WeatherRepositoryImpl(networkManager: mockNetwork, configuration: mockConfig)

		// When & Then
		await #expect(throws: WeatherError.configurationError) {
			try await repository.fetchCurrentWeather(latitude: 0, longitude: 0)
		}
	}

	@Test
	mutating func BaseURL이잘못되었을때_fetchCurrentWeather하면_configurationError를던지는지() async {
		// Given
		mockConfig.baseURL = ""
		let repository = WeatherRepositoryImpl(networkManager: mockNetwork, configuration: mockConfig)

		// When & Then
		await #expect(throws: WeatherError.configurationError) {
			try await repository.fetchCurrentWeather(latitude: 0, longitude: 0)
		}
	}

	@Test
	func 네트워크에러가발생할때_fetchCurrentWeather하면_networkError로변환되는지() async {
		// Given
		let realNetworkError = NetworkError.transport(URLError(.notConnectedToInternet))

		mockNetwork.errorToThrow = realNetworkError

		let repository = WeatherRepositoryImpl(networkManager: mockNetwork, configuration: mockConfig)

		// When & Then
		await #expect {
			try await repository.fetchCurrentWeather(latitude: 37.5, longitude: 127.0)
		} throws: { error in
			guard case .networkError(let message) = error as? WeatherError else {
				return false
			}

			return !message.isEmpty
		}
	}

	@Test
	func 음수온도응답이올때_fetchCurrentWeather하면_정상적으로처리되는지() async throws {
		// Given
		let dummyDTO = WeatherResponseDTO(
			weather: [.init(id: 600, main: "Snow", description: "heavy snow", icon: "13d")],
			main: .init(temp: -25.5, feelsLike: -30.0, tempMin: -28.0, tempMax: -20.0, pressure: 1020, humidity: 80),
			name: "Moscow"
		)
		mockNetwork.resultDTO = dummyDTO

		let repository = WeatherRepositoryImpl(networkManager: mockNetwork, configuration: mockConfig)

		// When
		let weather = try await repository.fetchCurrentWeather(latitude: 55.75, longitude: 37.61)

		// Then
		#expect(weather.temperature == -25.5)
		#expect(weather.condition == .snow)
		#expect(weather.cityName == "Moscow")
	}

	@Test
	func weather배열이비어있을때_fetchCurrentWeather하면_기본값으로처리되는지() async throws {
		// Given
		let dummyDTO = WeatherResponseDTO(
			weather: [],
			main: .init(temp: 20.0, feelsLike: 20.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, humidity: 55),
			name: "Test City"
		)
		mockNetwork.resultDTO = dummyDTO

		let repository = WeatherRepositoryImpl(networkManager: mockNetwork, configuration: mockConfig)

		// When
		let weather = try await repository.fetchCurrentWeather(latitude: 37.5, longitude: 127.0)

		// Then
		#expect(weather.temperature == 20.0)
		#expect(weather.condition == .clear)  // 기본값 800으로 처리
		#expect(weather.description == "")
		#expect(weather.iconCode == "")
	}
}
