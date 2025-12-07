//
//  GetArtistTimelineUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct GetArtistTimelineUseCaseTests {
	
	var mockRepository: MockMusicRepository
	
	init() {
		self.mockRepository = MockMusicRepository()
	}
	
	@Test("아티스트 타임라인 조회가 정상적으로 동작하는가")
	mutating func executeSuccess() async throws {
		// Given
		let artist = Artist(name: "Test Artist", imageURL: nil)
		let albums = [
			Album(title: "Album 1", artist: "Test Artist", imageURL: nil, releaseDate: nil),
			Album(title: "Album 2", artist: "Test Artist", imageURL: nil, releaseDate: nil)
		]
		mockRepository.fetchAlbumsResult = .success(albums)
		
		let useCase = GetArtistTimelineUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let result = try await useCase.execute(artist: artist)
		
		// Then
		#expect(result.count == 2)
		#expect(mockRepository.fetchAlbumsCallCount == 1)
		#expect(mockRepository.lastFetchAlbumsArtist?.name == "Test Artist")
	}
	
	@Test("앨범들이 발매일 기준 최신순으로 정렬되는가")
	mutating func executeSortsAlbumsByReleaseDate() async throws {
		// Given
		let artist = Artist(name: "Test Artist", imageURL: nil)
		
		let date1 = Date(timeIntervalSince1970: 1000000000) // 2001
		let date2 = Date(timeIntervalSince1970: 1500000000) // 2017
		let date3 = Date(timeIntervalSince1970: 1700000000) // 2023
		
		let albums = [
			Album(title: "Old Album", artist: "Test Artist", imageURL: nil, releaseDate: date1),
			Album(title: "New Album", artist: "Test Artist", imageURL: nil, releaseDate: date3),
			Album(title: "Mid Album", artist: "Test Artist", imageURL: nil, releaseDate: date2)
		]
		mockRepository.fetchAlbumsResult = .success(albums)
		
		let useCase = GetArtistTimelineUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let result = try await useCase.execute(artist: artist)
		
		// Then
		#expect(result.count == 3)
		#expect(result[0].title == "New Album") // 최신순
		#expect(result[1].title == "Mid Album")
		#expect(result[2].title == "Old Album")
	}
	
	@Test("발매일이 nil인 앨범은 뒤로 정렬되는가")
	mutating func executeSortsNilReleaseDateToEnd() async throws {
		// Given
		let artist = Artist(name: "Test Artist", imageURL: nil)
		
		let date1 = Date(timeIntervalSince1970: 1500000000)
		
		let albums = [
			Album(title: "No Date Album", artist: "Test Artist", imageURL: nil, releaseDate: nil),
			Album(title: "Album With Date", artist: "Test Artist", imageURL: nil, releaseDate: date1),
			Album(title: "Another No Date", artist: "Test Artist", imageURL: nil, releaseDate: nil)
		]
		mockRepository.fetchAlbumsResult = .success(albums)
		
		let useCase = GetArtistTimelineUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let result = try await useCase.execute(artist: artist)
		
		// Then
		#expect(result.count == 3)
		#expect(result[0].title == "Album With Date")
		// 나머지 두 개는 순서 상관없이 뒤에 위치
		#expect(result[1].releaseDate == nil)
		#expect(result[2].releaseDate == nil)
	}
	
	@Test("빈 앨범 리스트를 반환하면 빈 배열을 반환하는가")
	mutating func executeWithEmptyAlbums() async throws {
		// Given
		let artist = Artist(name: "Test Artist", imageURL: nil)
		mockRepository.fetchAlbumsResult = .success([])
		
		let useCase = GetArtistTimelineUseCaseImpl(musicRepository: mockRepository)
		
		// When
		let result = try await useCase.execute(artist: artist)
		
		// Then
		#expect(result.isEmpty)
		#expect(mockRepository.fetchAlbumsCallCount == 1)
	}
	
	@Test("Repository에서 에러가 발생하면 에러를 전파하는가")
	mutating func executeWithError() async {
		// Given
		enum TestError: Error {
			case testError
		}
		let artist = Artist(name: "Test Artist", imageURL: nil)
		mockRepository.fetchAlbumsResult = .failure(TestError.testError)
		
		let useCase = GetArtistTimelineUseCaseImpl(musicRepository: mockRepository)
		
		// When & Then
		await #expect(throws: TestError.self) {
			try await useCase.execute(artist: artist)
		}
	}
}

