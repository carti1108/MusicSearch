//
//  MusicRepositoryTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct MusicRepositoryTests {
	
	var mockNetwork: MockNetworkManager
	
	init() {
		self.mockNetwork = MockNetworkManager()
	}
	
	// MARK: - searchTracks Tests
	
	@Test("트랙 검색이 정상적으로 동작하는가")
	func searchTracksSuccess() async throws {
		// Given
		let searchDTO = TrackSearchResponseDTO(
			results: TrackMatchesContainerDTO(
				trackmatches: TrackListDTO(
					track: [
						LastFMTrackSearchDTO(
							name: "Test Track",
							artist: "Test Artist",
							url: "https://test.com",
							mbid: "test-mbid",
							image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/test.jpg")]
						)
					]
				)
			)
		)
		mockNetwork.resultDTOByMethod["track.search"] = searchDTO
		
		let repository = MusicRepositoryImpl(networkManager: mockNetwork)
		
		// When
		let tracks = try await repository.searchTracks(query: "test")
		
		// Then
		#expect(tracks.count == 1)
		#expect(tracks.first?.title == "Test Track")
		#expect(tracks.first?.artist == "Test Artist")
	}
	
	@Test("네트워크 에러 발생 시 에러를 던지는가")
	func searchTracksNetworkError() async {
		// Given
		mockNetwork.errorToThrow = NetworkError.transportError(URLError(.notConnectedToInternet))
		let repository = MusicRepositoryImpl(networkManager: mockNetwork)
		
		// When & Then
		await #expect(throws: NetworkError.self) {
			try await repository.searchTracks(query: "test")
		}
	}
	
	// MARK: - fetchTopTracks Tests
	
	@Test("태그 기반 Top 트랙 조회가 정상적으로 동작하는가")
	func fetchTopTracksSuccess() async throws {
		// Given
		let topTracksDTO = TagTopTracksResponseDTO(
			tracks: TagTrackListDTO(
				track: [
					LastFMTrackTagDTO(
						name: "Chill Track 1",
						artist: LastFMArtistDTO(
							name: "Chill Artist",
							mbid: nil,
							url: "https://test.com",
							image: nil,
							listeners: nil,
							tags: nil,
							bio: nil
						),
						url: "https://test.com",
						mbid: nil,
						image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/chill1.jpg")]
					),
					LastFMTrackTagDTO(
						name: "Chill Track 2",
						artist: LastFMArtistDTO(
							name: "Chill Artist 2",
							mbid: nil,
							url: "https://test.com",
							image: nil,
							listeners: nil,
							tags: nil,
							bio: nil
						),
						url: "https://test.com",
						mbid: nil,
						image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/chill2.jpg")]
					)
				]
			)
		)
		mockNetwork.resultDTOByMethod["tag.gettoptracks"] = topTracksDTO
		
		let repository = MusicRepositoryImpl(networkManager: mockNetwork)
		
		// When
		let tracks = try await repository.fetchTopTracks(by: "chill")
		
		// Then
		#expect(tracks.count == 2)
		#expect(tracks.first?.title == "Chill Track 1")
	}
	
	// MARK: - fetchSimilarTracks Tests
	
	@Test("유사 트랙 조회가 정상적으로 동작하는가")
	func fetchSimilarTracksSuccess() async throws {
		// Given
		let targetTrack = Track(title: "Original", artist: "Artist", imageURL: nil)
		
		let similarDTO = TrackSimilarResponseDTO(
			similartracks: SimilarTrackListDTO(
				track: [
					LastFMTrackSimilarDTO(
						name: "Similar Track 1",
						artist: LastFMArtistDTO(
							name: "Similar Artist 1",
							mbid: nil,
							url: "https://test.com",
							image: nil,
							listeners: nil,
							tags: nil,
							bio: nil
						),
						url: "https://test.com",
						mbid: nil,
						image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/similar1.jpg")]
					)
				]
			)
		)
		mockNetwork.resultDTOByMethod["track.getsimilar"] = similarDTO
		
		let repository = MusicRepositoryImpl(networkManager: mockNetwork)
		
		// When
		let tracks = try await repository.fetchSimilarTracks(to: targetTrack)
		
		// Then
		#expect(tracks.count == 1)
		#expect(tracks.first?.title == "Similar Track 1")
	}
	
	// MARK: - searchArtists Tests
	
	@Test("아티스트 검색이 정상적으로 동작하는가")
	func searchArtistsSuccess() async throws {
		// Given
		let searchDTO = ArtistSearchResponseDTO(
			results: ArtistMatchesContainerDTO(
				artistmatches: ArtistListDTO(
					artist: [
						LastFMArtistDTO(
							name: "Test Artist",
							mbid: "artist-mbid",
							url: "https://test.com",
							image: nil,
							listeners: "1000",
							tags: nil,
							bio: nil
						)
					]
				)
			)
		)
		mockNetwork.resultDTOByMethod["artist.search"] = searchDTO
		
		let repository = MusicRepositoryImpl(networkManager: mockNetwork)
		
		// When
		let artists = try await repository.searchArtists(query: "test")
		
		// Then
		#expect(artists.count == 1)
		#expect(artists.first?.name == "Test Artist")
		#expect(artists.first?.listeners == "1000")
	}

	@Test("트랙 getInfo가 정상적으로 동작하는가")
	func fetchTrackInfoSuccess() async throws {
		// Given
		let track = Track(title: "Test Track", artist: "Test Artist", imageURL: nil)
		let getInfoDTO = TrackInfoResponseDTO(
			track: LastFMTrackInfoDTO(
				name: "Test Track",
				artist: LastFMArtistDTO(
					name: "Test Artist",
					mbid: nil,
					url: "https://test.com",
					image: nil,
					listeners: nil,
					tags: nil,
					bio: nil
				),
				album: LastFMAlbumInfoDTO(
					title: "Album",
					image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/from_getinfo.jpg")]
				)
			)
		)
		mockNetwork.resultDTOByMethod["track.getInfo"] = getInfoDTO

		let repository = MusicRepositoryImpl(networkManager: mockNetwork)

		// When
		let enriched = try await repository.fetchTrackInfo(for: track)

		// Then
		#expect(enriched.imageURL?.absoluteString == "https://image.com/from_getinfo.jpg")
	}
	
	// MARK: - fetchAlbums Tests
	
	@Test("아티스트의 앨범 목록 조회가 정상적으로 동작하는가")
	func fetchAlbumsSuccess() async throws {
		// Given
		let artist = Artist(name: "Test Artist", imageURL: nil)
		
		let dummyDTO = ArtistTopAlbumsResponseDTO(
			topalbums: AlbumListDTO(
				album: [
					LastFMAlbumDTO(
						name: "Album 1",
						artist: LastFMArtistSimpleDTO(name: "Test Artist", mbid: nil, url: ""),
						mbid: "album-mbid",
						url: "https://test.com",
						image: nil,
						playcount: 5000,
						wiki: LastFMWikiDTO(published: "1 Jan 2020, 00:00", summary: "Test summary")
					)
				]
			)
		)
		mockNetwork.resultDTO = dummyDTO
		
		let repository = MusicRepositoryImpl(networkManager: mockNetwork)
		
		// When
		let albums = try await repository.fetchAlbums(for: artist)
		
		// Then
		#expect(albums.count == 1)
		#expect(albums.first?.title == "Album 1")
		#expect(albums.first?.artist == "Test Artist")
		#expect(albums.first?.playCount == 5000)
		#expect(albums.first?.releaseDate != nil)
	}
}

