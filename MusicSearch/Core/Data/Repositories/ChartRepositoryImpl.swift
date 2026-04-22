//
//  ChartRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation
import NetworkLayer

final class ChartRepositoryImpl: ChartRepository {

	private let networkManager: NetworkRequesting
	private let lastFMConfiguration: LastFMAPIConfiguration

	init(
		networkManager: NetworkRequesting,
		lastFMConfiguration: LastFMAPIConfiguration = DefaultLastFMAPIConfiguration()
	) {
		self.networkManager = networkManager
		self.lastFMConfiguration = lastFMConfiguration
	}

	func fetchTopTracks() async throws -> [Track] {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.getChartTopTracks(config: self.lastFMConfiguration),
			as: ChartTopTracksResponseDTO.self
		)

		return response.tracks.track.map { $0.toDomain() }
	}

	func fetchTopArtists() async throws -> [Artist] {
		let response = try await self.networkManager.perform(
			with: LastFMAPI.getChartTopArtists(config: self.lastFMConfiguration),
			as: ChartTopArtistsResponseDTO.self
		)

		return response.artists.artist.map { $0.toDomain() }
	}
}
