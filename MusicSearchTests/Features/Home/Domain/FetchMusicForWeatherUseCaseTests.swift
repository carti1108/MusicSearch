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

	@Test
	mutating func 위치와날씨정보를순차적으로잘가져올수있을때_execute하면_성공하는지() async throws {
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

	@Test
	mutating func 날씨조회중에러가발생할때_execute하면_에러를던지는지() async {
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

	@Test
	mutating func 트랙조회중에러가발생할때_execute하면_에러를던지는지() async {
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

	@Test
	mutating func 추천트랙이없을때_execute하면_빈트랙을가진결과를반환하는지() async throws {
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

	@Test
	mutating func 날씨가Clear일때_execute하면_Pop태그기반의트랙을반환하는지() async throws {
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

