//
//  MusicAppSearchTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import MSDomain
import Foundation

public struct MusicAppSearchTracksUseCaseImpl: SearchTracksUseCase {

	private let musicAppService: MusicAppService

	public init(musicAppService: MusicAppService) {
		self.musicAppService = musicAppService
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

		return try await self.musicAppService.searchTracks(
			query: normalizedQuery,
			limit: limit,
			offset: offset
		)
	}
}
