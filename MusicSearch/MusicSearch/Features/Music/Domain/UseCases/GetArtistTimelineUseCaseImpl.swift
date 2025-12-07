//
//  GetArtistTimelineUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

final class GetArtistTimelineUseCaseImpl: GetArtistTimelineUseCase {
	
	private let musicRepository: MusicRepository
	
	init(musicRepository: MusicRepository) {
		self.musicRepository = musicRepository
	}
	
	public func execute(artist: Artist) async throws -> [Album] {
		let albums = try await musicRepository.fetchAlbums(for: artist)
		
		return albums.sorted { lhs, rhs in
			guard let lhsDate = lhs.releaseDate else { return false }
			guard let rhsDate = rhs.releaseDate else { return true }
			return lhsDate > rhsDate
		}
	}
}
