//
//  FetchSimilarTrackUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchSimilarTracksUseCase {
	func execute(targetTrack: Track) async throws -> [Track]
}

final class FetchSimilarTrackUseCaseImpl: FetchSimilarTracksUseCase {
	
	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int = 8
	
	init(trackRepository: TrackRepository) {
		self.trackRepository = trackRepository
	}
	
	public func execute(targetTrack: Track) async throws -> [Track] {
		let tracks = try await self.trackRepository.fetchSimilarTracks(to: targetTrack)
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
					do {
						let enriched = try await self.trackRepository.fetchTrackInfo(for: next.element)
						return (next.offset, enriched)
					} catch {
						print("Failed to fetch track info for \(next.element.title): \(error)")
						return (next.offset, nil)
					}
				}
			}

			while let (index, enriched) = await group.next() {
				if let enriched = enriched {
					updated[index] = enriched
				}

				if let next = iterator.next() {
					group.addTask {
						do {
							let enriched = try await self.trackRepository.fetchTrackInfo(for: next.element)
							return (next.offset, enriched)
						} catch {
							print("Failed to fetch track info for \(next.element.title): \(error)")
							return (next.offset, nil)
						}
					}
				}
			}
		}

		return updated
	}
}
