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

	@Test("태그로 트랙 조회가 정상적으로 동작하는가")
	mutating func executeSuccess() async throws {
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

	@Test("빈 태그를 입력하면 빈 배열을 반환하는가")
	mutating func executeWithEmptyTag() async throws {
		// Given
		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: mockRepository)

		// When
		let tracks = try await useCase.execute(tag: "")

		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.fetchTopTracksCallCount == 0)
	}

	@Test("공백만 있는 태그를 입력하면 빈 배열을 반환하는가")
	mutating func executeWithWhitespaceTag() async throws {
		// Given
		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: mockRepository)

		// When
		let tracks = try await useCase.execute(tag: "   ")

		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.fetchTopTracksCallCount == 0)
	}

	@Test("다양한 태그로 조회가 가능한가")
	mutating func executeWithVariousTags() async throws {
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

	@Test("Repository에서 에러가 발생하면 에러를 전파하는가")
	mutating func executeWithError() async {
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
