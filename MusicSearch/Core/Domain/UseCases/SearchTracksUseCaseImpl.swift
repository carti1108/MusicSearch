//
//  SearchTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol SearchTracksUseCase {
	func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int)
}

final class SearchTracksUseCaseImpl: SearchTracksUseCase {

	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int = 8

	init(trackRepository: TrackRepository) {
		self.trackRepository = trackRepository
	}

	public func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return ([], 0)
		}

		let result = try await self.trackRepository.searchTracks(query: query, limit: limit, page: page)
		let enrichedTracks = await self.updateTracksWithDetails(result.tracks)

		return (enrichedTracks, result.totalResults)
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
