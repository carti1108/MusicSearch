//
//  Array+TrackInfo.swift
//  MusicSearch
//
//  Created by Kiseok on 4/18/26.
//

import Foundation

extension Array where Element == Track {
	func enrichingTrackInfo(
		maxConcurrentRequests: Int = 8,
		using fetchTrackInfo: @escaping @Sendable (Track) async throws -> Track
	) async -> [Track] {
		guard !self.isEmpty else { return [] }

		var enrichedTracks = self

		await withTaskGroup(of: (Int, Track?).self) { group in
			var iterator = self.enumerated().makeIterator()
			let initialRequestCount = Swift.min(maxConcurrentRequests, self.count)

			for _ in 0..<initialRequestCount {
				guard let next = iterator.next() else { break }
				group.addTask {
					await Self.enrichedTrackEntry(from: next, using: fetchTrackInfo)
				}
			}

			while let (index, enrichedTrack) = await group.next() {
				if let enrichedTrack {
					enrichedTracks[index] = enrichedTrack
				}

				guard let next = iterator.next() else { continue }
				group.addTask {
					await Self.enrichedTrackEntry(from: next, using: fetchTrackInfo)
				}
			}
		}

		return enrichedTracks
	}

	private static func enrichedTrackEntry(
		from entry: (offset: Int, element: Track),
		using fetchTrackInfo: @escaping @Sendable (Track) async throws -> Track
	) async -> (Int, Track?) {
		do {
			return (entry.offset, try await fetchTrackInfo(entry.element))
		} catch {
			return (entry.offset, nil)
		}
	}
}
