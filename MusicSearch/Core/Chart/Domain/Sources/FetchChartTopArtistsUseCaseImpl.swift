import MSDomain
//
//  FetchChartTopArtistsUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

public protocol FetchChartTopArtistsUseCase: Sendable {
	func execute() async throws -> [Artist]
}

public struct FetchChartTopArtistsUseCaseImpl: FetchChartTopArtistsUseCase {

	private let chartRepository: ChartRepository
	private let artistImageEnrichmentService: ArtistImageEnrichmentService?

	public init(
		chartRepository: ChartRepository,
		artistImageEnrichmentService: ArtistImageEnrichmentService? = nil
	) {
		self.chartRepository = chartRepository
		self.artistImageEnrichmentService = artistImageEnrichmentService
	}

	public func execute() async throws -> [Artist] {
		let artists = try await self.chartRepository.fetchTopArtists()
		guard let artistImageEnrichmentService else { return artists }
		return await artistImageEnrichmentService.enrich(artists)
	}
}
