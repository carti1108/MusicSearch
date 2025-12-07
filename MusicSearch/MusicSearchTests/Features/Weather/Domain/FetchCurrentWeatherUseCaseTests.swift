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

	@Test("위치와 날씨 정보를 순차적으로 잘 가져오는지 확인")
	func executeSuccess() async throws {
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

	@Test("위치 정보를 가져오는데 실패하면 즉시 에러를 던지고 중단하는가")
	func locationFailure() async {
		// Given
		mockLocationRepo.errorToThrow = WeatherError.locationFetchFailed

		// When & Then
		await #expect(throws: WeatherError.locationFetchFailed) {
			try await useCase.execute()
		}

		#expect(mockWeatherRepo.receivedLat == nil)
	}

	@Test("위치는 찾았으나 날씨 정보를 가져오는데 실패하면 에러를 던지는가")
	func weatherFailure() async {
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
