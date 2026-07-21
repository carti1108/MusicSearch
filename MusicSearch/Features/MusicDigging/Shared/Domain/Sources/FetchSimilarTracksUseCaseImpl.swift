//
//  FetchSimilarTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import MSDomain

import Foundation
import TrackSearchDomain

public protocol FetchSimilarTracksUseCase: Sendable {
	func execute(targetTrack: Track) async throws -> [Track]
}

public struct FetchSimilarTracksUseCaseImpl: FetchSimilarTracksUseCase {

	private let trackRepository: TrackRepository
	private let enrichTracksUseCase: EnrichTracksUseCase

	public init(trackRepository: TrackRepository, enrichTracksUseCase: EnrichTracksUseCase) {
		self.trackRepository = trackRepository
		self.enrichTracksUseCase = enrichTracksUseCase
	}

	public func execute(targetTrack: Track) async throws -> [Track] {
		let tracks = try await self.trackRepository.fetchSimilarTracks(to: targetTrack)
		return await self.enrichTracksUseCase.execute(tracks: tracks)
	}
}
