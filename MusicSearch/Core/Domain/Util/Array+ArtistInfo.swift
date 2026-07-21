//
//  Array+ArtistInfo.swift
//  MusicSearch
//
//  Created by Kiseok on 4/18/26.
//

import Foundation
import OSLog

public extension Array where Element == Artist {
	func enrichingArtistImage(
		maxConcurrentRequests: Int = 8,
		using fetchArtistImageURL: @escaping @Sendable (String) async throws -> URL?
	) async -> [Artist] {
		guard !self.isEmpty else { return [] }

		var updatedArtists = self

		do {
			try await withThrowingTaskGroup(of: (Int, URL?).self) { group in
				var iterator = self.enumerated().makeIterator()
				let initialCount = Swift.min(maxConcurrentRequests, self.count)

				for _ in 0..<initialCount {
					guard let next = iterator.next() else { break }
					group.addTask {
						try await Self.enrichedArtistImageEntry(from: next, using: fetchArtistImageURL)
					}
				}

				while let (index, imageURL) = try await group.next() {
					try Task.checkCancellation()
					if let imageURL {
						let artist = updatedArtists[index]
						updatedArtists[index] = Artist(
							id: artist.id,
							name: artist.name,
							imageURL: imageURL,
							listeners: artist.listeners,
							tags: artist.tags,
							bio: artist.bio
						)
					}

					guard let next = iterator.next() else { continue }
					group.addTask {
						try await Self.enrichedArtistImageEntry(from: next, using: fetchArtistImageURL)
					}
				}
			}
		} catch is CancellationError {
			return self
		} catch {
			Logger(subsystem: "MusicSearch", category: "Array+ArtistInfo").error("Parallel fetch failed: \(error.localizedDescription)")
			return updatedArtists
		}

		return updatedArtists
	}

	private static func enrichedArtistImageEntry(
		from entry: (offset: Int, element: Artist),
		using fetchArtistImageURL: @escaping @Sendable (String) async throws -> URL?
	) async throws -> (Int, URL?) {
		try Task.checkCancellation()
		do {
			return (entry.offset, try await fetchArtistImageURL(entry.element.name))
		} catch is CancellationError {
			throw CancellationError()
		} catch {
			Logger(subsystem: "MusicSearch", category: "Array+ArtistInfo").error("Fetch individual artist image failed: \(error.localizedDescription)")
			return (entry.offset, nil)
		}
	}
}
