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

	@Test
	func 날씨ID가200에서232사이일때_매핑하면_Thunderstorm으로변환되는지() {
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

	@Test
	func 날씨ID가300에서321사이일때_매핑하면_Drizzle로변환되는지() {
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

	@Test
	func 날씨ID가500에서531사이일때_매핑하면_Rain으로변환되는지() {
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

	@Test
	func 날씨ID가600에서622사이일때_매핑하면_Snow로변환되는지() {
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

	@Test
	func 날씨ID가701에서781사이일때_매핑하면_Atmosphere로변환되는지() {
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

	@Test
	func 날씨ID가800일때_매핑하면_Clear로변환되는지() {
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

	@Test
	func 날씨ID가801에서804사이일때_매핑하면_Clouds로변환되는지() {
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

	@Test
	func 범위를벗어난날씨ID일때_매핑하면_Unknown으로변환되는지() {
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

	@Test
	func 날씨ID가경계값인232일때_매핑하면_Thunderstorm으로변환되는지() {
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

	@Test
	func 날씨ID가경계값을벗어난233일때_매핑하면_Thunderstorm이아닌지() {
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

