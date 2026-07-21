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
	private let enrichTracksUseCase: EnrichTracksUseCase

	public init(chartRepository: ChartRepository, enrichTracksUseCase: EnrichTracksUseCase) {
		self.chartRepository = chartRepository
		self.enrichTracksUseCase = enrichTracksUseCase
	}

	public func execute() async throws -> [Track] {
		let tracks = try await self.chartRepository.fetchTopTracks()
		return await self.enrichTracksUseCase.execute(tracks: tracks)
	}
}
