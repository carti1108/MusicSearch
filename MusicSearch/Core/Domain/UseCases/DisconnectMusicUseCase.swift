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
        authService.disconnect()
    }
}
