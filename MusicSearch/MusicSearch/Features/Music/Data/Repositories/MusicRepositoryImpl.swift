//
//  MusicRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
import NetworkLayer

final class MusicRepositoryImpl: MusicRepository {

	private let networkManager: NetworkRequesting

	init(networkManager: NetworkRequesting = NetworkManager.shared) {
		self.networkManager = networkManager
	}

	func searchTracks(query: String) async throws -> [Track] {
		let response = try await networkManager.request(
			with: LastFMAPI.searchTracks(keyword: query),
			as: TrackSearchResponseDTO.self
		)

		return response.results.trackmatches.track.map { $0.toDomain() }
	}

	func fetchTopTracks(by tag: String) async throws -> [Track] {
		let response = try await networkManager.request(
			with: LastFMAPI.fetchTopTracks(tag: tag),
			as: TagTopTracksResponseDTO.self
		)
		return response.tracks.track.map { $0.toDomain() }
	}

	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		let response = try await networkManager.request(
			with: LastFMAPI.fetchSimilarTracks(track: track),
			as: TrackSimilarResponseDTO.self
		)
		return response.similartracks.track.map { $0.toDomain() }
	}

	func searchArtists(query: String) async throws -> [Artist] {
		let response = try await networkManager.request(
			with: LastFMAPI.searchArtists(keyword: query),
			as: ArtistSearchResponseDTO.self
		)
		return response.results.artistmatches.artist.map { $0.toDomain() }
	}

	func fetchAlbums(for artist: Artist) async throws -> [Album] {
		let response = try await networkManager.request(
			with: LastFMAPI.fetchArtistAlbums(artist: artist),
			as: ArtistTopAlbumsResponseDTO.self
		)
		return response.topalbums.album.map { $0.toDomain() }
	}
}
