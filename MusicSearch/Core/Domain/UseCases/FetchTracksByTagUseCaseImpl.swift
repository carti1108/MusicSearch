//
//  FetchTracksByTagUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchTracksByTagUseCase: Sendable {
	func execute(tag: String) async throws -> [Track]
}

public struct FetchTracksByTagUseCaseImpl: FetchTracksByTagUseCase {

	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int = 8

	public init(trackRepository: TrackRepository) {
		self.trackRepository = trackRepository
	}

	public func execute(tag: String) async throws -> [Track] {
		let normalizedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !normalizedTag.isEmpty else {
			return []
		}

		let tracks = try await self.trackRepository.fetchTopTracks(by: normalizedTag)
		return await self.enrichTrackInfo(for: tracks)
	}

	private func enrichTrackInfo(for tracks: [Track]) async -> [Track] {
		await tracks.enrichingTrackInfo(maxConcurrentRequests: self.maxConcurrentInfoRequests) { track in
			try await self.trackRepository.fetchTrackInfo(for: track)
		}
	}
}
