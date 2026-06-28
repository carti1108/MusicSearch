//
//  FetchChartTopTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import MSDomain

import Foundation
import TrackSearchDomain

public protocol FetchChartTopTracksUseCase: Sendable {
	func execute() async throws -> [Track]
}

public struct FetchChartTopTracksUseCaseImpl: FetchChartTopTracksUseCase {

	private let chartRepository: ChartRepository
	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int = 8

	public init(chartRepository: ChartRepository, trackRepository: TrackRepository) {
		self.chartRepository = chartRepository
		self.trackRepository = trackRepository
	}

	public func execute() async throws -> [Track] {
		let tracks = try await self.chartRepository.fetchTopTracks()
		return await self.enrichTrackInfo(for: tracks)
	}

	private func enrichTrackInfo(for tracks: [Track]) async -> [Track] {
		await tracks.enrichingTrackInfo(maxConcurrentRequests: self.maxConcurrentInfoRequests) { track in
			try await self.trackRepository.fetchTrackInfo(for: track)
		}
	}
}
