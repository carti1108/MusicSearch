//
//  FetchChartTopArtistsUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

protocol FetchChartTopArtistsUseCase: Sendable {
	func execute() async throws -> [Artist]
}

struct FetchChartTopArtistsUseCaseImpl: FetchChartTopArtistsUseCase {

	private let chartRepository: ChartRepository
	private let artistImageEnrichmentService: ArtistImageEnrichmentService?

	init(
		chartRepository: ChartRepository,
		artistImageEnrichmentService: ArtistImageEnrichmentService? = nil
	) {
		self.chartRepository = chartRepository
		self.artistImageEnrichmentService = artistImageEnrichmentService
	}

	func execute() async throws -> [Artist] {
		let artists = try await self.chartRepository.fetchTopArtists()
		guard let artistImageEnrichmentService else { return artists }
		return await artistImageEnrichmentService.enrich(artists)
	}
}
