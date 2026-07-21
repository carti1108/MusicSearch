//
//  ChartRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//


import Foundation
import NetworkLayer
import MSDomain
import ChartDomain
import MSInfrastructure

public struct ChartRepositoryImpl: ChartRepository {

	private let networkManager: NetworkRequesting

	public init(networkManager: NetworkRequesting) {
		self.networkManager = networkManager
	}

	public func fetchTopTracks() async throws -> [Track] {
		let response: ChartTopTracksResponseDTO = try await self.networkManager.perform(
			with: LastFMAPI.getChartTopTracks,
			as: ChartTopTracksResponseDTO.self
		)
		return response.tracks.track.map { $0.toDomain() }
	}

	public func fetchTopArtists() async throws -> [Artist] {
		let response: ChartTopArtistsResponseDTO = try await self.networkManager.perform(
			with: LastFMAPI.getChartTopArtists,
			as: ChartTopArtistsResponseDTO.self
		)
		return response.artists.artist.map { $0.toDomain() }
	}
}
