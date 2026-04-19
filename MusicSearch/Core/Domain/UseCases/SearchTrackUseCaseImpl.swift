//
//  SearchTrackUseCaseImpl.swift
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

final class SearchTrackUseCaseImpl: SearchTracksUseCase {

	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int = 8

	init(trackRepository: TrackRepository) {
		self.trackRepository = trackRepository
	}

	public func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !normalizedQuery.isEmpty else {
			return ([], 0)
		}

		let result = try await self.trackRepository.searchTracks(
			query: normalizedQuery,
			limit: limit,
			page: page
		)
		let enrichedTracks = await self.enrichTrackInfo(for: result.tracks)
		return (tracks: enrichedTracks, totalResults: result.totalResults)
	}

	private func enrichTrackInfo(for tracks: [Track]) async -> [Track] {
		await tracks.enrichingTrackInfo(maxConcurrentRequests: self.maxConcurrentInfoRequests) { track in
			try await self.trackRepository.fetchTrackInfo(for: track)
		}
	}
}
