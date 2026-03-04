//
//  ChartRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//


protocol ChartRepository {
	func fetchTopTracks() async throws -> [Track]
	func fetchTopArtists() async throws -> [Artist]
}
