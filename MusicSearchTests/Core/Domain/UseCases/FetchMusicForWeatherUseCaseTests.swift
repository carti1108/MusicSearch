//
//  FetchMusicForWeatherUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct FetchMusicForWeatherUseCaseTests {

	var mockWeatherUseCase: MockFetchCurrentWeatherUseCase
	var mockTrackUseCase: MockFetchTracksByTagUseCase

	init() {
		self.mockWeatherUseCase = MockFetchCurrentWeatherUseCase()
		self.mockTrackUseCase = MockFetchTracksByTagUseCase()
	}

	@Test("날씨, 태그, 트랙이 정상적으로 조합되어 WeatherMusicCuration을 반환하는가")
	mutating func executeSuccess() async throws {
		// Given
		let expectedWeather = Weather(
			temperature: 20.0,
			condition: .rain,
			description: "비",
			iconCode: "10d",
			cityName: "Seoul"
		)
		let expectedTracks = [
			Track(title: "Jazz Track", artist: "Jazz Artist", imageURL: nil),
			Track(title: "Blues Track", artist: "Blues Artist", imageURL: nil)
		]

		mockWeatherUseCase.result = expectedWeather
		mockTrackUseCase.result = expectedTracks

		let useCase = FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: mockWeatherUseCase,
			fetchTracksByTagUseCase: mockTrackUseCase
		)

		// When
		let curation = try await useCase.execute()

		// Then
		#expect(curation.weather.cityName == "Seoul")
		#expect(curation.weather.condition == .rain)
		#expect(curation.tracks.count == 2)

		let validTags = ["jazz", "blues", "lofi", "piano", "sad"]
		#expect(validTags.contains(curation.moodTag))

		#expect(mockWeatherUseCase.executeCallCount == 1)
		#expect(mockTrackUseCase.executeCallCount == 1)
		#expect(mockTrackUseCase.lastTag == curation.moodTag)
	}

	@Test("날씨 UseCase에서 에러가 발생하면 에러를 전파하는가")
	mutating func weatherUseCaseError() async {
		// Given
		enum TestError: Error {
			case weatherFailed
		}

		mockWeatherUseCase.errorToThrow = TestError.weatherFailed

		let useCase = FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: mockWeatherUseCase,
			fetchTracksByTagUseCase: mockTrackUseCase
		)

		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute()
		}

		#expect(mockTrackUseCase.executeCallCount == 0)
	}

	@Test("트랙 UseCase에서 에러가 발생하면 에러를 전파하는가")
	mutating func trackUseCaseError() async {
		// Given
		enum TestError: Error {
			case trackFetchFailed
		}

		let expectedWeather = Weather(
			temperature: 15.0,
			condition: .clear,
			description: "맑음",
			iconCode: "01d",
			cityName: "Busan"
		)

		mockWeatherUseCase.result = expectedWeather
		mockTrackUseCase.errorToThrow = TestError.trackFetchFailed

		let useCase = FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: mockWeatherUseCase,
			fetchTracksByTagUseCase: mockTrackUseCase
		)

		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute()
		}

		#expect(mockWeatherUseCase.executeCallCount == 1)
		#expect(mockTrackUseCase.executeCallCount == 1)
	}

	@Test("트랙이 빈 배열이어도 정상적으로 WeatherMusicCuration을 반환하는가")
	mutating func executeWithEmptyTracks() async throws {
		// Given
		let expectedWeather = Weather(
			temperature: 5.0,
			condition: .snow,
			description: "눈",
			iconCode: "13d",
			cityName: "Gangneung"
		)

		mockWeatherUseCase.result = expectedWeather
		mockTrackUseCase.result = []

		let useCase = FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: mockWeatherUseCase,
			fetchTracksByTagUseCase: mockTrackUseCase
		)

		// When
		let curation = try await useCase.execute()

		// Then
		#expect(curation.weather.cityName == "Gangneung")
		#expect(curation.weather.condition == .snow)
		#expect(curation.tracks.isEmpty)

		let validTags = ["christmas", "classical", "winter", "ambient"]
		#expect(validTags.contains(curation.moodTag))
	}

	@Test("clear 날씨 조건에서 적절한 태그가 매핑되는가")
	mutating func clearWeatherMapping() async throws {
		// Given
		let expectedWeather = Weather(
			temperature: 25.0,
			condition: .clear,
			description: "맑음",
			iconCode: "01d",
			cityName: "Jeju"
		)
		let expectedTracks = [
			Track(title: "Happy Song", artist: "Happy Artist", imageURL: nil)
		]

		mockWeatherUseCase.result = expectedWeather
		mockTrackUseCase.result = expectedTracks

		let useCase = FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: mockWeatherUseCase,
			fetchTracksByTagUseCase: mockTrackUseCase
		)

		// When
		let curation = try await useCase.execute()

		// Then
		let validTags = ["pop", "dance", "summer", "happy", "driving"]
		#expect(validTags.contains(curation.moodTag))
		#expect(mockTrackUseCase.lastTag == curation.moodTag)
	}
}

