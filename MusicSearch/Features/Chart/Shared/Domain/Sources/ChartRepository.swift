//
//  ChartRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import MSDomain

public protocol ChartRepository: Sendable {
	func fetchTopTracks() async throws -> [Track]
	func fetchTopArtists() async throws -> [Artist]
}
