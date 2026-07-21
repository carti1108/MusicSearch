//
//  FetchChartTopArtistsUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import MSDomain

public protocol FetchChartTopArtistsUseCase: Sendable {
	func execute() async throws -> [Artist]
}

public struct FetchChartTopArtistsUseCaseImpl: FetchChartTopArtistsUseCase {

	private let chartRepository: ChartRepository
	private let artistImageService: ArtistImageService?

	public init(
		chartRepository: ChartRepository,
		artistImageService: ArtistImageService? = nil
	) {
		self.chartRepository = chartRepository
		self.artistImageService = artistImageService
	}

	public func execute() async throws -> [Artist] {
		let artists = try await self.chartRepository.fetchTopArtists()
		guard let artistImageService else { return artists }
		
		return await artists.enrichingArtistImage { name in
			try await artistImageService.fetchImageURL(for: name)
		}
	}
}
