//
//  TrackRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation
import NetworkLayer

final class TrackRepositoryImpl: TrackRepository {

	private let networkManager: NetworkRequesting

	init(networkManager: NetworkRequesting) {
		self.networkManager = networkManager
	}

	func searchTracks(query: String) async throws -> [Track] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.searchTracks(keyword: query),
			as: TrackSearchResponseDTO.self
		)

		return response.results.trackmatches.track.map { $0.toDomain() }
	}
	
	func fetchTopTracks(by tag: String) async throws -> [Track] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.fetchTopTracks(tag: tag),
			as: TagTopTracksResponseDTO.self
		)

		return response.tracks.track.map { $0.toDomain() }
	}
	
	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.fetchSimilarTracks(track: track),
			as: TrackSimilarResponseDTO.self
		)

		return response.similartracks.track.map { $0.toDomain() }
	}
	
	func fetchTrackInfo(for track: Track) async throws -> Track {
		let trackInfoResponse = try await self.networkManager.request(
			with: LastFMAPI.getTrackInfo(track: track),
			as: TrackInfoResponseDTO.self
		)

		guard let album = trackInfoResponse.track.album,
			  let images = album.image else {
			return Track(id: track.id, title: track.title, artist: track.artist, imageURL: nil)
		}

		let imageString = images.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
					   ?? images.first { !$0.text.isEmpty }?.text

		let imageURL = imageString
			.flatMap { URL(string: $0) }?
			.forcedHTTPS

		return Track(
			id: track.id,
			title: track.title,
			artist: track.artist,
			imageURL: imageURL
		)
	}
}
