//
//  FetchChartTopTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

protocol FetchChartTopTracksUseCase {
	func execute() async throws -> [Track]
}

struct FetchChartTopTracksUseCaseImpl: FetchChartTopTracksUseCase {

	private let chartRepository: ChartRepository
	private let trackEnrichmentService: TrackEnrichmentService

	init(
		chartRepository: ChartRepository,
		trackRepository: TrackRepository,
		trackEnrichmentService: TrackEnrichmentService? = nil
	) {
		self.chartRepository = chartRepository
		self.trackEnrichmentService = trackEnrichmentService
			?? TrackEnrichmentServiceImpl(trackRepository: trackRepository)
	}

	func execute() async throws -> [Track] {
		let tracks = try await self.chartRepository.fetchTopTracks()
		return await self.trackEnrichmentService.enrich(tracks)
	}
}
