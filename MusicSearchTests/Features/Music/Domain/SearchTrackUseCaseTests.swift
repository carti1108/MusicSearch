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
	
	var mockRepository: MockMusicRepository
	
	init() {
		self.mockRepository = MockMusicRepository()
	}
	
	@Test("정상적인 쿼리로 트랙 검색이 동작하는가")
	mutating func executeSuccess() async throws {
		// Given
		let expectedTracks = [
			Track(title: "Track 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Track 2", artist: "Artist 2", imageURL: nil)
		]
		mockRepository.searchTracksResult = .success(expectedTracks)
		mockRepository.fetchTrackInfoResult = .success(Track(title: "Enriched", artist: "Enriched", imageURL: nil))
		
		let useCase = SearchTrackUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let tracks = try await useCase.execute(query: "test query")
		
		// Then
		#expect(tracks.count == 2)
		#expect(mockRepository.searchTracksCallCount == 1)
		#expect(mockRepository.fetchTrackInfoCallCount == 2)
		#expect(mockRepository.lastSearchTracksQuery == "test query")
	}
	
	@Test("빈 쿼리를 입력하면 빈 배열을 반환하는가")
	mutating func executeWithEmptyQuery() async throws {
		// Given
		let useCase = SearchTrackUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let tracks = try await useCase.execute(query: "")
		
		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.searchTracksCallCount == 0)
	}
	
	@Test("공백만 있는 쿼리를 입력하면 빈 배열을 반환하는가")
	mutating func executeWithWhitespaceQuery() async throws {
		// Given
		let useCase = SearchTrackUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let tracks = try await useCase.execute(query: "   ")
		
		// Then
		#expect(tracks.isEmpty)
		#expect(mockRepository.searchTracksCallCount == 0)
	}
	
	@Test("Repository에서 에러가 발생하면 에러를 전파하는가")
	mutating func executeWithError() async {
		// Given
		enum TestError: Error {
			case testError
		}
		mockRepository.searchTracksResult = .failure(TestError.testError)
		
		let useCase = SearchTrackUseCaseImpl(musicRepository: mockRepository)
		
		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute(query: "test")
		}
	}
}

