//
//  TrackRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

protocol TrackRepository {
	func searchTracks(query: String) async throws -> [Track]

	func fetchTopTracks(by tag: String) async throws -> [Track]

	func fetchSimilarTracks(to track: Track) async throws -> [Track]

	func fetchTrackInfo(for track: Track) async throws -> Track
}
