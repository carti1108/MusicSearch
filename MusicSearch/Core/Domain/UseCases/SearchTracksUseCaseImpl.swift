//
//  SearchTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol SearchTracksUseCase {
	func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int)
}

final class SearchTracksUseCaseImpl: SearchTracksUseCase {

	private let trackRepository: TrackRepository
	private let trackEnrichmentService: TrackEnrichmentService

	init(
		trackRepository: TrackRepository,
		trackEnrichmentService: TrackEnrichmentService? = nil
	) {
		self.trackRepository = trackRepository
		self.trackEnrichmentService = trackEnrichmentService
			?? TrackEnrichmentServiceImpl(trackRepository: trackRepository)
	}

	public func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return ([], 0)
		}

		let result = try await self.trackRepository.searchTracks(query: query, limit: limit, page: page)
		let enrichedTracks = await self.trackEnrichmentService.enrich(result.tracks)

		return (enrichedTracks, result.totalResults)
	}
}
