//
//  TrackEnrichmentService.swift
//  MusicSearch
//
//  Created by Kiseok on 4/14/26.
//

import Foundation

protocol TrackEnrichmentService {
	func enrich(_ tracks: [Track]) async -> [Track]
}

final class TrackEnrichmentServiceImpl: TrackEnrichmentService {
	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int

	init(
		trackRepository: TrackRepository,
		maxConcurrentInfoRequests: Int = 8
	) {
		self.trackRepository = trackRepository
		self.maxConcurrentInfoRequests = maxConcurrentInfoRequests
	}

	func enrich(_ tracks: [Track]) async -> [Track] {
		guard !tracks.isEmpty else { return [] }

		var updatedTracks = tracks

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
				if let enriched {
					updatedTracks[index] = enriched
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

		return updatedTracks
	}
}
