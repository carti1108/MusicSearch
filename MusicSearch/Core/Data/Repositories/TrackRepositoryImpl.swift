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
	private let lastFMConfiguration: LastFMAPIConfiguration

	init(
		networkManager: NetworkRequesting,
		lastFMConfiguration: LastFMAPIConfiguration = DefaultLastFMAPIConfiguration()
	) {
		self.networkManager = networkManager
		self.lastFMConfiguration = lastFMConfiguration
	}

	func searchTracks(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.searchTracks(
				keyword: query,
				limit: limit,
				page: page,
				config: self.lastFMConfiguration
			),
			as: TrackSearchResponseDTO.self
		)

		let tracks = response.results.trackmatches.track.map { $0.toDomain() }
		let totalResults = Int(response.results.totalResults) ?? 0

		return (tracks, totalResults)
	}

	func fetchTopTracks(by tag: String) async throws -> [Track] {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.fetchTopTracks(tag: tag, config: self.lastFMConfiguration),
			as: TagTopTracksResponseDTO.self
		)

		return response.tracks.track.map { $0.toDomain() }
	}

	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.fetchSimilarTracks(track: track, config: self.lastFMConfiguration),
			as: TrackSimilarResponseDTO.self
		)

		return response.similartracks.track.map { $0.toDomain() }
	}

	func fetchTrackInfo(for track: Track) async throws -> Track {
		let trackInfoResponse = try await self.networkManager.perform(
			with: LastFMAPI.getTrackInfo(track: track, config: self.lastFMConfiguration),
			as: TrackInfoResponseDTO.self
		)

		guard let album = trackInfoResponse.track.album,
			  let images = album.image else {
			return Track(
				id: track.id,
				mbid: track.mbid,
				title: track.title,
				artist: track.artist,
				imageURL: nil
			)
		}

		let imageString = images.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
					   ?? images.first { !$0.text.isEmpty }?.text

		let imageURL = imageString
			.flatMap { URL(string: $0) }?
			.secureURL

		return Track(
			id: track.id,
			mbid: track.mbid,
			title: track.title,
			artist: track.artist,
			imageURL: imageURL
		)
	}
}
