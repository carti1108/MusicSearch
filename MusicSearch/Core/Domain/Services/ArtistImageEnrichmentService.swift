//
//  ArtistImageEnrichmentService.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation
import OSLog

public protocol ArtistImageEnrichmentService: Sendable {
	func enrich(_ artists: [Artist]) async -> [Artist]
}

public final class ArtistImageEnrichmentServiceImpl: ArtistImageEnrichmentService {
	private let fetchArtistImageURLUseCase: FetchArtistImageURLUseCase
	private let maxConcurrentImageRequests: Int

	public init(
		fetchArtistImageURLUseCase: FetchArtistImageURLUseCase,
		maxConcurrentImageRequests: Int = 8
	) {
		self.fetchArtistImageURLUseCase = fetchArtistImageURLUseCase
		self.maxConcurrentImageRequests = maxConcurrentImageRequests
	}

	public func enrich(_ artists: [Artist]) async -> [Artist] {
		guard !artists.isEmpty else { return [] }

		var updatedArtists = artists

		do {
			try await withThrowingTaskGroup(of: (Int, URL?).self) { group in
				var iterator = artists.enumerated().makeIterator()

				let initialCount = min(self.maxConcurrentImageRequests, artists.count)
				for _ in 0..<initialCount {
					guard let next = iterator.next() else { break }
					let offset = next.offset
					let name = next.element.name
					group.addTask { [fetchArtistImageURLUseCase] in
						try await Self.enrichedArtistImageEntry(
							offset: offset,
							name: name,
							fetchArtistImageURLUseCase: fetchArtistImageURLUseCase
						)
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

					if let next = iterator.next() {
						let offset = next.offset
						let name = next.element.name
						group.addTask { [fetchArtistImageURLUseCase] in
							try await Self.enrichedArtistImageEntry(
								offset: offset,
								name: name,
								fetchArtistImageURLUseCase: fetchArtistImageURLUseCase
							)
						}
					}
				}
			}
		} catch is CancellationError {
			return artists
		} catch {
			Logger(subsystem: "MusicSearch", category: "ArtistImageEnrichmentService").error("Enrichment failed: \(error.localizedDescription)")
			return updatedArtists
		}

		return updatedArtists
	}

	private static func enrichedArtistImageEntry(
		offset: Int,
		name: String,
		fetchArtistImageURLUseCase: FetchArtistImageURLUseCase
	) async throws -> (Int, URL?) {
		try Task.checkCancellation()
		do {
			let imageURL = try await fetchArtistImageURLUseCase.execute(artistName: name)
			return (offset, imageURL)
		} catch is CancellationError {
			throw CancellationError()
		} catch {
			Logger(subsystem: "MusicSearch", category: "ArtistImageEnrichmentService").error("Fetch image for artist failed: \(error.localizedDescription)")
			return (offset, nil)
		}
	}
}
