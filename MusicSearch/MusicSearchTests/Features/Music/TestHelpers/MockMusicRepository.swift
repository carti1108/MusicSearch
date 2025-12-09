//
//  MockMusicRepository.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
@testable import MusicSearch

final class MockMusicRepository: MusicRepository {
	
	var searchTracksResult: Result<[Track], Error> = .success([])
	var fetchTopTracksResult: Result<[Track], Error> = .success([])
	var fetchSimilarTracksResult: Result<[Track], Error> = .success([])
	var searchArtistsResult: Result<[Artist], Error> = .success([])
	var fetchAlbumsResult: Result<[Album], Error> = .success([])
	
	var searchTracksCallCount = 0
	var fetchTopTracksCallCount = 0
	var fetchSimilarTracksCallCount = 0
	var searchArtistsCallCount = 0
	var fetchAlbumsCallCount = 0
	
	var lastSearchTracksQuery: String?
	var lastFetchTopTracksTag: String?
	var lastFetchSimilarTracksTrack: Track?
	var lastSearchArtistsQuery: String?
	var lastFetchAlbumsArtist: Artist?
	
	func searchTracks(query: String) async throws -> [Track] {
		self.searchTracksCallCount += 1
		self.lastSearchTracksQuery = query
		
		switch self.searchTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
	
	func fetchTopTracks(by tag: String) async throws -> [Track] {
		self.fetchTopTracksCallCount += 1
		self.lastFetchTopTracksTag = tag
		
		switch self.fetchTopTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
	
	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		self.fetchSimilarTracksCallCount += 1
		self.lastFetchSimilarTracksTrack = track
		
		switch self.fetchSimilarTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
	
	func searchArtists(query: String) async throws -> [Artist] {
		self.searchArtistsCallCount += 1
		self.lastSearchArtistsQuery = query
		
		switch self.searchArtistsResult {
		case .success(let artists):
			return artists
		case .failure(let error):
			throw error
		}
	}
	
	func fetchAlbums(for artist: Artist) async throws -> [Album] {
		self.fetchAlbumsCallCount += 1
		self.lastFetchAlbumsArtist = artist
		
		switch self.fetchAlbumsResult {
		case .success(let albums):
			return albums
		case .failure(let error):
			throw error
		}
	}
}

