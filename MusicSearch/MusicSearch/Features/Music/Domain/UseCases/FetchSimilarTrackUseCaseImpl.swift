//
//  FetchSimilarTrackUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

final class FetchSimilarTrackUseCaseImpl: FetchSimilarTracksUseCase {
	
	private let musicRepository: MusicRepository
	
	init(musicRepository: MusicRepository) {
		self.musicRepository = musicRepository
	}
	
	public func execute(targetTrack: Track) async throws -> [Track] {
		return try await musicRepository.fetchSimilarTracks(to: targetTrack)
	}
}
