//
//  FetchTracksByTagUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct FetchTracksByTagUseCaseTests {

	var mockRepository: MockTrackRepository

	init() {
		self.mockRepository = MockTrackRepository()
	}

	@Test
	mutating func 위치와날씨정보를순차적으로잘가져올수있을때_execute하면_성공하는지() async throws {
		// Given
		let expectedTracks = [
			Track(title: "Chill Track 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Chill Track 2", artist: "Artist 2", imageURL: nil)
		]
		mockRepository.fetchTopTracksResult = .success(expectedTracks)
		mockRepository.fetchTrackInfoResult = .success(Track(title: "Enriched", artist: "Enriched", imageURL: nil))

		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: mockRepository)

		// When
		let tracks = try await useCase.execute(tag: "chill")

		// Then
		#expect(tracks.count == 2)
		#expect(mockRepository.fetchTopTracksCallCount == 1)
		#expect(mockRepository.fetchTrackInfoCallCount == 2)
		#expect(mockRepository.lastFetchTopTracksTag == "chill")
	}

	@Test
	mutating func 빈태그일때_execute하면_빈결과를반환하는지() async throws {
		// Given
		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: mockRepository)

		// When
		let tracks = try await useCase.execute(tag: "")

		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.fetchTopTracksCallCount == 0)
	}

	@Test
	mutating func 공백태그일때_execute하면_빈결과를반환하는지() async throws {
		// Given
		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: mockRepository)

		// When
		let tracks = try await useCase.execute(tag: "   ")

		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.fetchTopTracksCallCount == 0)
	}

	@Test
	mutating func 다양한형태의태그일때_execute하면_정상적으로트랙을반환하는지() async throws {
		// Given
		mockRepository.fetchTopTracksResult = .success([
			Track(title: "Track", artist: "Artist", imageURL: nil)
		])
		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: mockRepository)

		// When & Then
		let tags = ["rock", "pop", "jazz", "chill", "ambient"]
		for tag in tags {
			_ = try await useCase.execute(tag: tag)
			#expect(mockRepository.lastFetchTopTracksTag == tag)
		}

		#expect(mockRepository.fetchTopTracksCallCount == tags.count)
	}

	@Test
	mutating func 검색중네트워크에러가발생할때_execute하면_에러를던지는지() async {
		// Given
		enum TestError: Error {
			case testError
		}
		mockRepository.fetchTopTracksResult = .failure(TestError.testError)

		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: mockRepository)

		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute(tag: "rock")
		}
	}
}
