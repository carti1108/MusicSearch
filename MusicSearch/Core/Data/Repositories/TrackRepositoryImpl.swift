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

	func searchTracks(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.searchTracks(keyword: query, limit: limit, page: page),
			as: TrackSearchResponseDTO.self
		)

		let tracks = response.results.trackmatches.track.map { $0.toDomain() }
		let totalResults = Int(response.results.totalResults) ?? 0
		
		return (tracks, totalResults)
	}
	
	func fetchTopTracks(by tag: String) async throws -> [Track] {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.fetchTopTracks(tag: tag),
			as: TagTopTracksResponseDTO.self
		)

		return response.tracks.track.map { $0.toDomain() }
	}
	
	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.fetchSimilarTracks(track: track),
			as: TrackSimilarResponseDTO.self
		)

		return response.similartracks.track.map { $0.toDomain() }
	}
	
	func fetchTrackInfo(for track: Track) async throws -> Track {
		let trackInfoResponse = try await self.networkManager.perform(
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
