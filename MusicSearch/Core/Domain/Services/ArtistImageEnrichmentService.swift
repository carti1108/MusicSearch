//
//  ArtistImageEnrichmentService.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation

protocol ArtistImageEnrichmentService: Sendable {
	func enrich(_ artists: [Artist]) async -> [Artist]
}

final class ArtistImageEnrichmentServiceImpl: ArtistImageEnrichmentService {
	private let fetchArtistImageURLUseCase: FetchArtistImageURLUseCase
	private let maxConcurrentImageRequests: Int

	init(
		fetchArtistImageURLUseCase: FetchArtistImageURLUseCase,
		maxConcurrentImageRequests: Int = 8
	) {
		self.fetchArtistImageURLUseCase = fetchArtistImageURLUseCase
		self.maxConcurrentImageRequests = maxConcurrentImageRequests
	}

	func enrich(_ artists: [Artist]) async -> [Artist] {
		guard !artists.isEmpty else { return [] }

		var updatedArtists = artists

		await withTaskGroup(of: (Int, URL?).self) { group in
			var iterator = artists.enumerated().makeIterator()

			let initialCount = min(self.maxConcurrentImageRequests, artists.count)
			for _ in 0..<initialCount {
				guard let next = iterator.next() else { break }
				let offset = next.offset
				let name = next.element.name
				group.addTask { [fetchArtistImageURLUseCase] in
					do {
						let imageURL = try await fetchArtistImageURLUseCase.execute(artistName: name)
						return (offset, imageURL)
					} catch {
						print("Failed to fetch artist image for \(name): \(error)")
						return (offset, nil)
					}
				}
			}

			while let (index, imageURL) = await group.next() {
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
						do {
							let imageURL = try await fetchArtistImageURLUseCase.execute(artistName: name)
							return (offset, imageURL)
						} catch {
							print("Failed to fetch artist image for \(name): \(error)")
							return (offset, nil)
						}
					}
				}
			}
		}

		return updatedArtists
	}
}
