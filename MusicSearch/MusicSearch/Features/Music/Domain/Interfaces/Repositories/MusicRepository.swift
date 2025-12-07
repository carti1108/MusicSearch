//
//  MusicRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol MusicRepository {

	func searchTracks(query: String) async throws -> [Track]

	func fetchTopTracks(by tag: String) async throws -> [Track]

	func fetchSimilarTracks(to track: Track) async throws -> [Track]

	func searchArtists(query: String) async throws -> [Artist]

	func fetchAlbums(for artist: Artist) async throws -> [Album]
}
