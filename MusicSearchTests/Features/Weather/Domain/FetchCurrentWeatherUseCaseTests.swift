//
//  FetchCurrentWeatherUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/5/25.
//

import Foundation
import Testing
@testable import MusicSearch

struct FetchCurrentWeatherUseCaseTests {

	var mockLocationRepo: MockLocationRepository
	var mockWeatherRepo: MockWeatherRepository
	var useCase: FetchCurrentWeatherUseCaseImpl

	init() {
		self.mockLocationRepo = MockLocationRepository()
		self.mockWeatherRepo = MockWeatherRepository()
		self.useCase = FetchCurrentWeatherUseCaseImpl(
			locationRepository: mockLocationRepo,
			weatherRepository: mockWeatherRepo
		)
	}

	@Test
	func 위치와날씨정보를순차적으로잘가져올수있을때_execute하면_성공하는지() async throws {
		// Given
		mockLocationRepo.result = (latitude: 37.5, longitude: 127.0)
		mockWeatherRepo.result = Weather(
			temperature: 20,
			condition: .clear,
			description: "맑음",
			iconCode: "01d",
			cityName: "Seoul"
		)

		// When
		let weather = try await useCase.execute()

		// Then
		#expect(weather.condition == .clear)
		#expect(weather.cityName == "Seoul")
		#expect(mockWeatherRepo.receivedLat == 37.5)
		#expect(mockWeatherRepo.receivedLon == 127.0)
	}

	@Test
	func 위치정보를가져오는데실패할때_execute하면_즉시에러를던지고중단하는지() async {
		// Given
		mockLocationRepo.errorToThrow = WeatherError.locationFetchFailed

		// When & Then
		await #expect(throws: WeatherError.locationFetchFailed) {
			try await useCase.execute()
		}

		#expect(mockWeatherRepo.receivedLat == nil)
	}

	@Test
	func 위치는찾았으나날씨정보를가져오는데실패할때_execute하면_에러를던지는지() async {
		// Given
		mockLocationRepo.result = (latitude: 37.5, longitude: 127.0)
		mockWeatherRepo.errorToThrow = WeatherError.networkError("Time out")

		// When & Then
		await #expect {
			try await useCase.execute()
		} throws: { error in
			guard case .networkError = error as? WeatherError else { return false }
			return true
		}
	}
}
