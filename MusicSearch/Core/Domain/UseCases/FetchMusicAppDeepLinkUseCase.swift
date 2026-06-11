//  FetchMusicAppDeepLinkUseCase.swift

import Foundation

public protocol FetchMusicAppDeepLinkUseCase: Sendable {
	func execute(track: Track) async -> URL?
	func execute(artist: String) async -> URL?
}

public final class FetchMusicAppDeepLinkUseCaseImpl: FetchMusicAppDeepLinkUseCase {
	private let musicAppRepository: MusicAppRepository

	public init(musicAppRepository: MusicAppRepository) {
		self.musicAppRepository = musicAppRepository
	}

	public func execute(track: Track) async -> URL? {
		return await self.musicAppRepository.fetchDeepLink(for: track)
	}

	public func execute(artist: String) async -> URL? {
		return await self.musicAppRepository.fetchDeepLink(for: artist)
	}
}
