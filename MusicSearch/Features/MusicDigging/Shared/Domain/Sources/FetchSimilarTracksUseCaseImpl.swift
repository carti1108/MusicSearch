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
	private let maxConcurrentInfoRequests: Int = 8

	public init(trackRepository: TrackRepository) {
		self.trackRepository = trackRepository
	}

	public func execute(targetTrack: Track) async throws -> [Track] {
		let tracks = try await self.trackRepository.fetchSimilarTracks(to: targetTrack)
		return await self.enrichTrackInfo(for: tracks)
	}

	private func enrichTrackInfo(for tracks: [Track]) async -> [Track] {
		await tracks.enrichingTrackInfo(maxConcurrentRequests: self.maxConcurrentInfoRequests) { track in
			try await self.trackRepository.fetchTrackInfo(for: track)
		}
	}
}
