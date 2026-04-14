//
//  FetchTracksByTagUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchTracksByTagUseCase {
	func execute(tag: String) async throws -> [Track]
}

final class FetchTracksByTagUseCaseImpl: FetchTracksByTagUseCase {

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

	public func execute(tag: String) async throws -> [Track] {
		guard !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return []
		}

		let tracks = try await self.trackRepository.fetchTopTracks(by: tag)
		return await self.trackEnrichmentService.enrich(tracks)
	}
}
