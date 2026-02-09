//
//  FetchChartTopTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

protocol FetchChartTopTracksUseCase {
	func execute() async throws -> [Track]
}

struct FetchChartTopTracksUseCaseImpl: FetchChartTopTracksUseCase {

	private let chartRepository: ChartRepository
	private let trackRepository: TrackRepository
	private let maxConcurrentInfoRequests: Int = 8

	init(chartRepository: ChartRepository, trackRepository: TrackRepository) {
		self.chartRepository = chartRepository
		self.trackRepository = trackRepository
	}

	func execute() async throws -> [Track] {
		let tracks = try await self.chartRepository.fetchTopTracks()
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
