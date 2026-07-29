//
//  DisconnectMusicUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation

public protocol DisconnectMusicUseCase: Sendable {
    func execute()
}

public final class DisconnectMusicUseCaseImpl: DisconnectMusicUseCase {
    private let authService: MusicAuthService

    public init(authService: MusicAuthService) {
        self.authService = authService
    }

    public func execute() {
        self.authService.disconnect()
    }
}
