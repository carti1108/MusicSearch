//
//  FetchChartTopTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

protocol FetchChartTopTracksUseCase: Sendable {
	func execute() async throws -> [Track]
}

struct FetchChartTopTracksUseCaseImpl: FetchChartTopTracksUseCase {

	private let chartRepository: ChartRepository
	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int = 8

	init(chartRepository: ChartRepository, trackRepository: TrackRepository) {
		self.chartRepository = chartRepository
		self.trackRepository = trackRepository
	}

	func execute() async throws -> [Track] {
		let tracks = try await self.chartRepository.fetchTopTracks()
		return await self.enrichTrackInfo(for: tracks)
	}

	private func enrichTrackInfo(for tracks: [Track]) async -> [Track] {
		await tracks.enrichingTrackInfo(maxConcurrentRequests: self.maxConcurrentInfoRequests) { track in
			try await self.trackRepository.fetchTrackInfo(for: track)
		}
	}
}
