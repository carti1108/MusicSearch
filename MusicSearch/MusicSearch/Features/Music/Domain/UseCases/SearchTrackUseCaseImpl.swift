//
//  SearchTrackUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

final class SearchTrackUseCaseImpl: SearchTracksUseCase {
	
	private let musicRepository: MusicRepository
	
	init(musicRepository: MusicRepository) {
		self.musicRepository = musicRepository
	}
	
	public func execute(query: String) async throws -> [Track] {
		guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return []
		}
		
		return try await musicRepository.searchTracks(query: query)
	}
}
