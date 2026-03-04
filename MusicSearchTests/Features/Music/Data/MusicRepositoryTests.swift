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

struct TrackRepositoryTests {

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
				),
				totalResults: "1",
				startIndex: "0",
				itemsPerPage: "30"
			)
		)
		mockNetwork.resultDTOByMethod["track.search"] = searchDTO

		let repository = TrackRepositoryImpl(networkManager: mockNetwork)

		// When
		let result = try await repository.searchTracks(query: "test", limit: 30, page: 1)
		let tracks = result.tracks
		let totalResults = result.totalResults

		// Then
		#expect(tracks.count == 1)
		#expect(tracks.first?.title == "Test Track")
		#expect(tracks.first?.artist == "Test Artist")
		#expect(totalResults == 1)
	}

	@Test("네트워크 에러 발생 시 에러를 던지는가")
	func searchTracksNetworkError() async {
		// Given
		mockNetwork.errorToThrow = NetworkError.transportError(URLError(.notConnectedToInternet))
		let repository = TrackRepositoryImpl(networkManager: mockNetwork)

		// When & Then
		await #expect(throws: NetworkError.self) {
			_ = try await repository.searchTracks(query: "test", limit: 30, page: 1)
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
						artist: LastFMArtistNameDTO(
							name: "Chill Artist",
							mbid: nil,
							url: "https://test.com"
						),
						url: "https://test.com",
						mbid: nil,
						image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/chill1.jpg")]
					),
					LastFMTrackTagDTO(
						name: "Chill Track 2",
						artist: LastFMArtistNameDTO(
							name: "Chill Artist 2",
							mbid: nil,
							url: "https://test.com"
						),
						url: "https://test.com",
						mbid: nil,
						image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/chill2.jpg")]
					)
				]
			)
		)
		mockNetwork.resultDTOByMethod["tag.gettoptracks"] = topTracksDTO

		let repository = TrackRepositoryImpl(networkManager: mockNetwork)

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
						artist: LastFMArtistNameDTO(
							name: "Similar Artist 1",
							mbid: nil,
							url: "https://test.com"
						),
						url: "https://test.com",
						mbid: nil,
						image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/similar1.jpg")]
					)
				]
			)
		)
		mockNetwork.resultDTOByMethod["track.getsimilar"] = similarDTO

		let repository = TrackRepositoryImpl(networkManager: mockNetwork)

		// When
		let tracks = try await repository.fetchSimilarTracks(to: targetTrack)

		// Then
		#expect(tracks.count == 1)
		#expect(tracks.first?.title == "Similar Track 1")
	}

	@Test("트랙 getInfo가 정상적으로 동작하는가")
	func fetchTrackInfoSuccess() async throws {
		// Given
		let track = Track(title: "Test Track", artist: "Test Artist", imageURL: nil)
		let getInfoDTO = TrackInfoResponseDTO(
			track: LastFMTrackInfoDTO(
				name: "Test Track",
				artist: LastFMArtistNameDTO(
					name: "Test Artist",
					mbid: nil,
					url: "https://test.com"
				),
				album: LastFMAlbumInfoDTO(
					title: "Album",
					image: [LastFMImageDTO(size: "extralarge", text: "https://image.com/from_getinfo.jpg")]
				)
			)
		)
		mockNetwork.resultDTOByMethod["track.getInfo"] = getInfoDTO

		let repository = TrackRepositoryImpl(networkManager: mockNetwork)

		// When
		let enriched = try await repository.fetchTrackInfo(for: track)

		// Then
		#expect(enriched.imageURL?.absoluteString == "https://image.com/from_getinfo.jpg")
	}
}
