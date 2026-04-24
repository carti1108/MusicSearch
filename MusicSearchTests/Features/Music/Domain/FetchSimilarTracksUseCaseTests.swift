//
//  FetchSimilarTracksUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct FetchSimilarTracksUseCaseTests {

	var mockRepository: MockTrackRepository

	init() {
		self.mockRepository = MockTrackRepository()
	}

	@Test
	mutating func 위치와날씨정보를순차적으로잘가져올수있을때_execute하면_성공하는지() async throws {
		// Given
		let targetTrack = Track(title: "Original Track", artist: "Original Artist", imageURL: nil)
		let similarTracks = [
			Track(title: "Similar 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Similar 2", artist: "Artist 2", imageURL: nil)
		]
		mockRepository.fetchSimilarTracksResult = .success(similarTracks)
		mockRepository.fetchTrackInfoResult = .success(Track(title: "Enriched", artist: "Enriched", imageURL: nil))

		let useCase = FetchSimilarTracksUseCaseImpl(trackRepository: mockRepository)

		// When
		let result = try await useCase.execute(targetTrack: targetTrack)

		// Then
		#expect(result.count == 2)
		#expect(mockRepository.fetchSimilarTracksCallCount == 1)
		#expect(mockRepository.fetchTrackInfoCallCount == 2)
		#expect(mockRepository.lastFetchSimilarTracksTrack?.title == "Original Track")
	}

	@Test
	mutating func 유사트랙이없을때_execute하면_빈결과를반환하는지() async throws {
		// Given
		let targetTrack = Track(title: "Test Track", artist: "Test Artist", imageURL: nil)
		mockRepository.fetchSimilarTracksResult = .success([])

		let useCase = FetchSimilarTracksUseCaseImpl(trackRepository: mockRepository)

		// When
		let result = try await useCase.execute(targetTrack: targetTrack)

		// Then
		#expect(result.isEmpty)
		#expect(mockRepository.fetchSimilarTracksCallCount == 1)
	}

	@Test
	mutating func 검색중네트워크에러가발생할때_execute하면_에러를던지는지() async {
		// Given
		enum TestError: Error {
			case testError
		}
		let targetTrack = Track(title: "Test Track", artist: "Test Artist", imageURL: nil)
		mockRepository.fetchSimilarTracksResult = .failure(TestError.testError)

		let useCase = FetchSimilarTracksUseCaseImpl(trackRepository: mockRepository)

		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute(targetTrack: targetTrack)
		}
	}
}
