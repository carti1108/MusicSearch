//
//  SearchArtistUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

final class SearchArtistUseCaseImpl: SearchArtistsUseCase {
	
	private let musicRepository: MusicRepository
	
	init(musicRepository: MusicRepository) {
		self.musicRepository = musicRepository
	}
	
	public func execute(query: String) async throws -> [Artist] {
		guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return []
		}
		
		return try await self.musicRepository.searchArtists(query: query)
	}
}
