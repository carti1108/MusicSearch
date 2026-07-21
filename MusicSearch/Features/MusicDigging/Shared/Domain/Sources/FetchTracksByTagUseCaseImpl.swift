//
//  FetchTracksByTagUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import MSDomain

import Foundation
import TrackSearchDomain

public protocol FetchTracksByTagUseCase: Sendable {
	func execute(tag: String) async throws -> [Track]
}

public struct FetchTracksByTagUseCaseImpl: FetchTracksByTagUseCase {

	private let trackRepository: TrackRepository
	private let enrichTracksUseCase: EnrichTracksUseCase

	public init(trackRepository: TrackRepository, enrichTracksUseCase: EnrichTracksUseCase) {
		self.trackRepository = trackRepository
		self.enrichTracksUseCase = enrichTracksUseCase
	}

	public func execute(tag: String) async throws -> [Track] {
		let normalizedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !normalizedTag.isEmpty else {
			return []
		}

		let tracks = try await self.trackRepository.fetchTopTracks(by: normalizedTag)
		return await self.enrichTracksUseCase.execute(tracks: tracks)
	}
}
