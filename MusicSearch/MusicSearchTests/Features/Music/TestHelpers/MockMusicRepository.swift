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
		searchTracksCallCount += 1
		lastSearchTracksQuery = query
		
		switch searchTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
	
	func fetchTopTracks(by tag: String) async throws -> [Track] {
		fetchTopTracksCallCount += 1
		lastFetchTopTracksTag = tag
		
		switch fetchTopTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
	
	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		fetchSimilarTracksCallCount += 1
		lastFetchSimilarTracksTrack = track
		
		switch fetchSimilarTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
	
	func searchArtists(query: String) async throws -> [Artist] {
		searchArtistsCallCount += 1
		lastSearchArtistsQuery = query
		
		switch searchArtistsResult {
		case .success(let artists):
			return artists
		case .failure(let error):
			throw error
		}
	}
	
	func fetchAlbums(for artist: Artist) async throws -> [Album] {
		fetchAlbumsCallCount += 1
		lastFetchAlbumsArtist = artist
		
		switch fetchAlbumsResult {
		case .success(let albums):
			return albums
		case .failure(let error):
			throw error
		}
	}
}

