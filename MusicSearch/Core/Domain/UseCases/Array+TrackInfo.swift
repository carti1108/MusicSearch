//
//  Array+TrackInfo.swift
//  MusicSearch
//
//  Created by Kiseok on 4/18/26.
//

import Foundation
import OSLog

public extension Array where Element == Track {
	func enrichingTrackInfo(
		maxConcurrentRequests: Int = 8,
		using fetchTrackInfo: @escaping @Sendable (Track) async throws -> Track
	) async -> [Track] {
		guard !self.isEmpty else { return [] }

		var enrichedTracks = self

		do {
			try await withThrowingTaskGroup(of: (Int, Track?).self) { group in
				var iterator = self.enumerated().makeIterator()
				let initialRequestCount = Swift.min(maxConcurrentRequests, self.count)

				for _ in 0..<initialRequestCount {
					guard let next = iterator.next() else { break }
					group.addTask {
						try await Self.enrichedTrackEntry(from: next, using: fetchTrackInfo)
					}
				}

				while let (index, enrichedTrack) = try await group.next() {
					try Task.checkCancellation()
					if let enrichedTrack {
						enrichedTracks[index] = enrichedTrack
					}

					guard let next = iterator.next() else { continue }
					group.addTask {
						try await Self.enrichedTrackEntry(from: next, using: fetchTrackInfo)
					}
				}
			}
		} catch is CancellationError {
			return self
		} catch {
			Logger(subsystem: "MusicSearch", category: "Array+TrackInfo").error("Parallel fetch failed: \(error.localizedDescription)")
			return enrichedTracks
		}

		return enrichedTracks
	}

	private static func enrichedTrackEntry(
		from entry: (offset: Int, element: Track),
		using fetchTrackInfo: @escaping @Sendable (Track) async throws -> Track
	) async throws -> (Int, Track?) {
		try Task.checkCancellation()
		do {
			return (entry.offset, try await fetchTrackInfo(entry.element))
		} catch is CancellationError {
			throw CancellationError()
		} catch {
			Logger(subsystem: "MusicSearch", category: "Array+TrackInfo").error("Fetch individual track failed: \(error.localizedDescription)")
			return (entry.offset, nil)
		}
	}
}
