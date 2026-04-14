//
//  FetchSimilarTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchSimilarTracksUseCase {
	func execute(targetTrack: Track) async throws -> [Track]
}

final class FetchSimilarTracksUseCaseImpl: FetchSimilarTracksUseCase {

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

	public func execute(targetTrack: Track) async throws -> [Track] {
		let tracks = try await self.trackRepository.fetchSimilarTracks(to: targetTrack)
		return await self.trackEnrichmentService.enrich(tracks)
	}
}
