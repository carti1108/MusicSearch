//
//  GetMusicAccessTokenUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation

public protocol GetMusicAccessTokenUseCase: Sendable {
    func execute() -> String?
}

public final class GetMusicAccessTokenUseCaseImpl: GetMusicAccessTokenUseCase {
    private let authService: MusicAuthService

    public init(authService: MusicAuthService) {
        self.authService = authService
    }

    public func execute() -> String? {
        return authService.getAccessToken()
    }
}
