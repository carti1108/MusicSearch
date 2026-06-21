import Foundation

public protocol ManageSpotifyAuthUseCase: Sendable {
    func getAccessToken() -> String?
    func authorize() async throws
    func disconnect()
}

public final class ManageSpotifyAuthUseCaseImpl: ManageSpotifyAuthUseCase {
    private let authRepository: SpotifyAuthRepository
    
    public init(authRepository: SpotifyAuthRepository) {
        self.authRepository = authRepository
    }
    
    public func getAccessToken() -> String? {
        return authRepository.getAccessToken()
    }
    
    public func authorize() async throws {
        try await authRepository.authorize()
    }
    
    public func disconnect() {
        authRepository.disconnect()
    }
}
