//
//  FetchChartTopArtistsUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

protocol FetchChartTopArtistsUseCase {
	func execute() async throws -> [Artist]
}

struct FetchChartTopArtistsUseCaseImpl: FetchChartTopArtistsUseCase {

	private let chartRepository: ChartRepository

	init(chartRepository: ChartRepository) {
		self.chartRepository = chartRepository
	}

	func execute() async throws -> [Artist] {
		try await self.chartRepository.fetchTopArtists()
	}
}
