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

	@Test("네트워크 응답이 정상적일 때, Weather Domain Entity로 잘 변환되는가")
	func fetchSuccess() async throws {
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

	@Test("API Key가 비어있으면 configurationError를 던지는가")
	mutating func invalidAPIKey() async {
		// Given
		mockConfig.apiKey = ""
		let repository = WeatherRepositoryImpl(networkManager: mockNetwork, configuration: mockConfig)

		// When & Then
		await #expect(throws: WeatherError.configurationError) {
			try await repository.fetchCurrentWeather(latitude: 0, longitude: 0)
		}
	}

	@Test("Base URL이 잘못되었으면 configurationError를 던지는가")
	mutating func invalidURL() async {
		// Given
		mockConfig.baseURL = ""
		let repository = WeatherRepositoryImpl(networkManager: mockNetwork, configuration: mockConfig)

		// When & Then
		await #expect(throws: WeatherError.configurationError) {
			try await repository.fetchCurrentWeather(latitude: 0, longitude: 0)
		}
	}

	@Test("네트워크 에러 발생 시 WeatherError.networkError로 변환되는가")
	func networkFailure() async {
		// Given
		let realNetworkError = NetworkError.transportError(URLError(.notConnectedToInternet))

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

	@Test("음수 온도도 정상적으로 처리되는가")
	func negativeTemperature() async throws {
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

	@Test("weather 배열이 비어있을 때 기본값으로 처리되는가")
	func emptyWeatherArray() async throws {
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
