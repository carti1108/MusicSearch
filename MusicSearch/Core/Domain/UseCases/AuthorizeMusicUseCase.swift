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
        try await authService.authorize()
    }
}
