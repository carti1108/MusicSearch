//
//  FetchSimilarTrackUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct FetchSimilarTrackUseCaseTests {
	
	var mockRepository: MockTrackRepository
	
	init() {
		self.mockRepository = MockTrackRepository()
	}
	
	@Test("유사 트랙 조회가 정상적으로 동작하는가")
	mutating func executeSuccess() async throws {
		// Given
		let targetTrack = Track(title: "Original Track", artist: "Original Artist", imageURL: nil)
		let similarTracks = [
			Track(title: "Similar 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Similar 2", artist: "Artist 2", imageURL: nil)
		]
		mockRepository.fetchSimilarTracksResult = .success(similarTracks)
		mockRepository.fetchTrackInfoResult = .success(Track(title: "Enriched", artist: "Enriched", imageURL: nil))
		
		let useCase = FetchSimilarTrackUseCaseImpl(trackRepository: mockRepository)
		
		// When
		let result = try await useCase.execute(targetTrack: targetTrack)
		
		// Then
		#expect(result.count == 2)
		#expect(mockRepository.fetchSimilarTracksCallCount == 1)
		#expect(mockRepository.fetchTrackInfoCallCount == 2)
		#expect(mockRepository.lastFetchSimilarTracksTrack?.title == "Original Track")
	}
	
	@Test("Repository에서 빈 배열을 반환하면 빈 배열을 반환하는가")
	mutating func executeWithEmptyResult() async throws {
		// Given
		let targetTrack = Track(title: "Test Track", artist: "Test Artist", imageURL: nil)
		mockRepository.fetchSimilarTracksResult = .success([])
		
		let useCase = FetchSimilarTrackUseCaseImpl(trackRepository: mockRepository)
		
		// When
		let result = try await useCase.execute(targetTrack: targetTrack)
		
		// Then
		#expect(result.isEmpty)
		#expect(mockRepository.fetchSimilarTracksCallCount == 1)
	}
	
	@Test("Repository에서 에러가 발생하면 에러를 전파하는가")
	mutating func executeWithError() async {
		// Given
		enum TestError: Error {
			case testError
		}
		let targetTrack = Track(title: "Test Track", artist: "Test Artist", imageURL: nil)
		mockRepository.fetchSimilarTracksResult = .failure(TestError.testError)
		
		let useCase = FetchSimilarTrackUseCaseImpl(trackRepository: mockRepository)
		
		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute(targetTrack: targetTrack)
		}
	}
}
