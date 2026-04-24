//
//  ChartRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation
import NetworkLayer

struct ChartRepositoryImpl: ChartRepository {

	private let networkManager: NetworkRequesting

	init(networkManager: NetworkRequesting) {
		self.networkManager = networkManager
	}

	func fetchTopTracks() async throws -> [Track] {
		let response: ChartTopTracksResponseDTO = try await self.networkManager.perform(
			with: LastFMAPI.getChartTopTracks,
			as: ChartTopTracksResponseDTO.self
		)
		return response.tracks.track.map { $0.toDomain() }
	}

	func fetchTopArtists() async throws -> [Artist] {
		let response: ChartTopArtistsResponseDTO = try await self.networkManager.perform(
			with: LastFMAPI.getChartTopArtists,
			as: ChartTopArtistsResponseDTO.self
		)
		return response.artists.artist.map { $0.toDomain() }
	}
}
