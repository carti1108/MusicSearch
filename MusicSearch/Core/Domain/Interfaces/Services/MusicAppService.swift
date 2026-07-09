//
//  MusicAppService.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation

public protocol MusicAppService: Sendable {
	func fetchDeepLink(for track: Track) async -> URL?
	func fetchDeepLink(for artist: String) async -> URL?
	func searchSpotifyTracks(query: String, limit: Int, offset: Int) async throws -> (tracks: [Track], totalResults: Int)
}
