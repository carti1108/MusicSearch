//
//  WeatherDTOTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct WeatherDTOTests {

	@Test("날씨 ID 200-232는 Thunderstorm으로 변환")
	func convertThunderstorm() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 200, main: "Thunderstorm", description: "thunderstorm", icon: "11d")],
			main: .init(temp: 25.0, feelsLike: 25.0, tempMin: 20.0, tempMax: 30.0, pressure: 1000, humidity: 80),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .thunderstorm)
	}

	@Test("날씨 ID 300-321은 Drizzle로 변환")
	func convertDrizzle() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 310, main: "Drizzle", description: "drizzle", icon: "09d")],
			main: .init(temp: 15.0, feelsLike: 15.0, tempMin: 10.0, tempMax: 20.0, pressure: 1000, humidity: 70),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .drizzle)
	}

	@Test("날씨 ID 500-531은 Rain으로 변환")
	func convertRain() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 501, main: "Rain", description: "rain", icon: "10d")],
			main: .init(temp: 18.0, feelsLike: 18.0, tempMin: 15.0, tempMax: 22.0, pressure: 1000, humidity: 85),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .rain)
	}

	@Test("날씨 ID 600-622는 Snow로 변환")
	func convertSnow() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 600, main: "Snow", description: "snow", icon: "13d")],
			main: .init(temp: -5.0, feelsLike: -8.0, tempMin: -10.0, tempMax: 0.0, pressure: 1000, humidity: 90),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .snow)
	}

	@Test("날씨 ID 701-781은 Atmosphere로 변환")
	func convertAtmosphere() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 721, main: "Haze", description: "haze", icon: "50d")],
			main: .init(temp: 28.0, feelsLike: 30.0, tempMin: 25.0, tempMax: 32.0, pressure: 1000, humidity: 60),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .atmosphere)
	}

	@Test("날씨 ID 800은 Clear로 변환")
	func convertClear() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
			main: .init(temp: 22.0, feelsLike: 22.0, tempMin: 20.0, tempMax: 25.0, pressure: 1013, humidity: 50),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .clear)
	}

	@Test("날씨 ID 801-804는 Clouds로 변환")
	func convertClouds() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 802, main: "Clouds", description: "clouds", icon: "03d")],
			main: .init(temp: 20.0, feelsLike: 20.0, tempMin: 18.0, tempMax: 23.0, pressure: 1010, humidity: 65),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .clouds)
	}

	@Test("범위 밖 날씨 ID는 Unknown으로 변환")
	func convertUnknown() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 999, main: "Unknown", description: "unknown", icon: "99d")],
			main: .init(temp: 20.0, feelsLike: 20.0, tempMin: 18.0, tempMax: 22.0, pressure: 1013, humidity: 55),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .unknown)
	}

	@Test("경계값 - ID 232(Thunderstorm 최대)")
	func boundaryThunderstormMax() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 232, main: "Thunderstorm", description: "test", icon: "11d")],
			main: .init(temp: 20.0, feelsLike: 20.0, tempMin: 18.0, tempMax: 22.0, pressure: 1000, humidity: 50),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .thunderstorm)
	}

	@Test("경계값 - ID 233은 Thunderstorm이 아님")
	func boundaryThunderstormOverflow() {
		// Given
		let dto = WeatherResponseDTO(
			weather: [.init(id: 233, main: "Test", description: "test", icon: "test")],
			main: .init(temp: 20.0, feelsLike: 20.0, tempMin: 18.0, tempMax: 22.0, pressure: 1000, humidity: 50),
			name: "TestCity"
		)

		// When
		let weather = dto.toDomain()

		// Then
		#expect(weather.condition == .unknown)
	}
}

