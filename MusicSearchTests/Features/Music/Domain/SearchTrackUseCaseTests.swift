//
//  SearchTrackUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct SearchTrackUseCaseTests {

	var mockRepository: MockTrackRepository

	init() {
		self.mockRepository = MockTrackRepository()
	}

	@Test
	mutating func 위치와날씨정보를순차적으로잘가져올수있을때_execute하면_성공하는지() async throws {
		// Given
		let expectedTracks = [
			Track(title: "Track 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Track 2", artist: "Artist 2", imageURL: nil)
		]
		mockRepository.searchTracksResult = .success((expectedTracks, 2))
		mockRepository.fetchTrackInfoResult = .success(Track(title: "Enriched", artist: "Enriched", imageURL: nil))

		let useCase = SearchTrackUseCaseImpl(trackRepository: mockRepository)

		// When
		let result = try await useCase.execute(query: "test query", limit: 20, page: 1)
		let tracks = result.tracks

		// Then
		#expect(tracks.count == 2)
		#expect(mockRepository.searchTracksCallCount == 1)
		#expect(mockRepository.fetchTrackInfoCallCount == 2)
		#expect(mockRepository.lastSearchTracksQuery == "test query")
	}

	@Test
	mutating func 빈검색어일때_execute하면_빈결과를반환하는지() async throws {
		// Given
		let useCase = SearchTrackUseCaseImpl(trackRepository: mockRepository)

		// When
		let result = try await useCase.execute(query: "", limit: 20, page: 1)
		let tracks = result.tracks

		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.searchTracksCallCount == 0)
	}

	@Test
	mutating func 공백검색어일때_execute하면_빈결과를반환하는지() async throws {
		// Given
		let useCase = SearchTrackUseCaseImpl(trackRepository: mockRepository)

		// When
		let result = try await useCase.execute(query: "   ", limit: 20, page: 1)
		let tracks = result.tracks

		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.searchTracksCallCount == 0)
	}

	@Test
	mutating func 검색중네트워크에러가발생할때_execute하면_에러를던지는지() async {
		// Given
		enum TestError: Error {
			case testError
		}
		mockRepository.searchTracksResult = .failure(TestError.testError)

		let useCase = SearchTrackUseCaseImpl(trackRepository: mockRepository)

		// When & Then
		await #expect(throws: TestError.self) {
			_ = try await useCase.execute(query: "test", limit: 20, page: 1)
		}
	}
}

