//
//  SearchTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import MSDomain
import Foundation

public protocol SearchTracksUseCase: Sendable {
	func execute(
		query: String,
		limit: Int,
		offset: Int
	) async throws -> (tracks: [Track], totalResults: Int)
}

public struct SearchTracksUseCaseImpl: SearchTracksUseCase {

	private let trackRepository: TrackRepository
	private let musicAppService: MusicAppService?
	private let enrichTracksUseCase: EnrichTracksUseCase

	public init(
		trackRepository: TrackRepository,
		musicAppService: MusicAppService? = nil,
		enrichTracksUseCase: EnrichTracksUseCase
	) {
		self.trackRepository = trackRepository
		self.musicAppService = musicAppService
		self.enrichTracksUseCase = enrichTracksUseCase
	}

	public func execute(
		query: String,
		limit: Int,
		offset: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !normalizedQuery.isEmpty else {
			return ([], 0)
		}

		if let musicAppService {
			do {
				let result = try await musicAppService.searchTracks(query: normalizedQuery, limit: limit, offset: offset)
				if !result.tracks.isEmpty {
					let enrichedTracks = await self.enrichTracksUseCase.execute(tracks: result.tracks)
					return (tracks: enrichedTracks, totalResults: result.totalResults)
				}
			} catch {
				// Fallback to TrackRepository
			}
		}

		let result = try await self.trackRepository.searchTracks(
			query: normalizedQuery,
			limit: limit,
			offset: offset
		)
		let enrichedTracks = await self.enrichTracksUseCase.execute(tracks: result.tracks)
		return (tracks: enrichedTracks, totalResults: result.totalResults)
	}
}
