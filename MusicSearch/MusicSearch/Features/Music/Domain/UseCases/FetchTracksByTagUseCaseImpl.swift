//
//  FetchTracksByTagUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

final class FetchTracksByTagUseCaseImpl: FetchTracksByTagUseCase {
	
	private let musicRepository: MusicRepository
	
	init(musicRepository: MusicRepository) {
		self.musicRepository = musicRepository
	}
	
	public func execute(tag: String) async throws -> [Track] {
		guard !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return []
		}
		
		return try await self.musicRepository.fetchTopTracks(by: tag)
	}
}
