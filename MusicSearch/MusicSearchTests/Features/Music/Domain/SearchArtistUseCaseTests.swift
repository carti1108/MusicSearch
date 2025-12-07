//
//  SearchArtistUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct SearchArtistUseCaseTests {
	
	var mockRepository: MockMusicRepository
	
	init() {
		self.mockRepository = MockMusicRepository()
	}
	
	@Test("정상적인 쿼리로 아티스트 검색이 동작하는가")
	mutating func executeSuccess() async throws {
		// Given
		let expectedArtists = [
			Artist(name: "Artist 1", imageURL: nil),
			Artist(name: "Artist 2", imageURL: nil)
		]
		mockRepository.searchArtistsResult = .success(expectedArtists)
		
		let useCase = SearchArtistUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let artists = try await useCase.execute(query: "test artist")
		
		// Then
		#expect(artists.count == 2)
		#expect(mockRepository.searchArtistsCallCount == 1)
		#expect(mockRepository.lastSearchArtistsQuery == "test artist")
	}
	
	@Test("빈 쿼리를 입력하면 빈 배열을 반환하는가")
	mutating func executeWithEmptyQuery() async throws {
		// Given
		let useCase = SearchArtistUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let artists = try await useCase.execute(query: "")
		
		// Then
		#expect(artists.isEmpty)
		#expect(mockRepository.searchArtistsCallCount == 0)
	}
	
	@Test("공백만 있는 쿼리를 입력하면 빈 배열을 반환하는가")
	mutating func executeWithWhitespaceQuery() async throws {
		// Given
		let useCase = SearchArtistUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let artists = try await useCase.execute(query: "   \n  ")
		
		// Then
		#expect(artists.isEmpty)
		#expect(mockRepository.searchArtistsCallCount == 0)
	}
	
	@Test("Repository에서 에러가 발생하면 에러를 전파하는가")
	mutating func executeWithError() async {
		// Given
		enum TestError: Error {
			case testError
		}
		mockRepository.searchArtistsResult = .failure(TestError.testError)
		
		let useCase = SearchArtistUseCaseImpl(musicRepository: mockRepository)
		
		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute(query: "test")
		}
	}
}

