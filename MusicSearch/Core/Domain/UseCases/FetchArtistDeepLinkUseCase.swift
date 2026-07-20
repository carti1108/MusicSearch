//
//  FetchArtistDeepLinkUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation

public protocol FetchArtistDeepLinkUseCase: Sendable {
    func execute(artist: String) async -> URL?
}

public final class FetchArtistDeepLinkUseCaseImpl: FetchArtistDeepLinkUseCase {
    private let musicAppService: MusicAppService

    public init(musicAppService: MusicAppService) {
        self.musicAppService = musicAppService
    }

    public func execute(artist: String) async -> URL? {
        return await self.musicAppService.fetchDeepLink(for: artist)
    }
}
