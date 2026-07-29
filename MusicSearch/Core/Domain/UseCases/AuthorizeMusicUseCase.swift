//
//  AuthorizeMusicUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation

public protocol AuthorizeMusicUseCase: Sendable {
    func execute() async throws
}

public final class AuthorizeMusicUseCaseImpl: AuthorizeMusicUseCase {
    private let authService: MusicAuthService

    public init(authService: MusicAuthService) {
        self.authService = authService
    }

    public func execute() async throws {
        try await self.authService.authorize()
    }
}
