//  FetchMusicAppDeepLinkUseCase.swift

import Foundation

protocol FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL?
	func execute(artist: String) async -> URL?
}

final class FetchMusicAppDeepLinkUseCaseImpl: FetchMusicAppDeepLinkUseCase {
	private let musicAppRepository: MusicAppRepository

	init(musicAppRepository: MusicAppRepository) {
		self.musicAppRepository = musicAppRepository
	}

	func execute(track: Track) async -> URL? {
		return await self.musicAppRepository.fetchDeepLink(for: track)
	}

	func execute(artist: String) async -> URL? {
		return await self.musicAppRepository.fetchDeepLink(for: artist)
	}
}
