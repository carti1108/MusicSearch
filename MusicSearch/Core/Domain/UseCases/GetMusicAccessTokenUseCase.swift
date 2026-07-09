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
