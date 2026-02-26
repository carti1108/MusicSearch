//
//  MockTrackRepository.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
@testable import MusicSearch

final class MockTrackRepository: TrackRepository {
	
	var searchTracksResult: Result<(tracks: [Track], totalResults: Int), Error> = .success(([], 0))
	var fetchTopTracksResult: Result<[Track], Error> = .success([])
	var fetchSimilarTracksResult: Result<[Track], Error> = .success([])
	var fetchTrackInfoResult: Result<Track, Error> = .success(Track(title: "Mock Track", artist: "Mock Artist", imageURL: nil))
	
	var searchTracksCallCount = 0
	var fetchTopTracksCallCount = 0
	var fetchSimilarTracksCallCount = 0
	var fetchTrackInfoCallCount = 0
	
	var lastSearchTracksQuery: String?
	var lastFetchTopTracksTag: String?
	var lastFetchSimilarTracksTrack: Track?
	var lastFetchTrackInfoTrack: Track?
	
	func searchTracks(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
		self.searchTracksCallCount += 1
		self.lastSearchTracksQuery = query
		
		switch self.searchTracksResult {
		case .success(let result):
			return result
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

	func fetchTrackInfo(for track: Track) async throws -> Track {
		self.fetchTrackInfoCallCount += 1
		self.lastFetchTrackInfoTrack = track

		switch self.fetchTrackInfoResult {
		case .success(let track):
			return track
		case .failure(let error):
			throw error
		}
	}
}
