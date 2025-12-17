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
	private let maxConcurrentInfoRequests: Int = 8
	
	init(trackRepository: TrackRepository) {
		self.trackRepository = trackRepository
	}
	
	public func execute(tag: String) async throws -> [Track] {
		guard !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return []
		}
		
		let tracks = try await self.trackRepository.fetchTopTracks(by: tag)
		return await self.updateTracksWithDetails(tracks)
	}

	private func updateTracksWithDetails(_ tracks: [Track]) async -> [Track] {
		guard !tracks.isEmpty else { return [] }

		var updated = tracks

		await withTaskGroup(of: (Int, Track?).self) { group in
			var iterator = tracks.enumerated().makeIterator()

			let initialCount = min(self.maxConcurrentInfoRequests, tracks.count)
			for _ in 0..<initialCount {
				guard let next = iterator.next() else { break }
				group.addTask {
					let enriched = try? await self.trackRepository.fetchTrackInfo(for: next.element)
					return (next.offset, enriched)
				}
			}

			while let (index, enriched) = await group.next() {
				if let enriched = enriched {
					updated[index] = enriched
				}

				if let next = iterator.next() {
					group.addTask {
						let enriched = try? await self.trackRepository.fetchTrackInfo(for: next.element)
						return (next.offset, enriched)
					}
				}
			}
		}

		return updated
	}
}
