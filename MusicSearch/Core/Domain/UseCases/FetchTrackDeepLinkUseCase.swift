//
//  FetchTrackDeepLinkUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation

public protocol FetchTrackDeepLinkUseCase: Sendable {
    func execute(track: Track) async -> URL?
}

public final class FetchTrackDeepLinkUseCaseImpl: FetchTrackDeepLinkUseCase {
    private let musicAppService: MusicAppService

    public init(musicAppService: MusicAppService) {
        self.musicAppService = musicAppService
    }

    public func execute(track: Track) async -> URL? {
        return await self.musicAppService.fetchDeepLink(for: track)
    }
}
