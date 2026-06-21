import Foundation

public protocol FetchSpotifyProfileUseCase: Sendable {
    func execute() async throws -> (name: String, imageURL: URL?)
}

public final class FetchSpotifyProfileUseCaseImpl: FetchSpotifyProfileUseCase {
    private let authRepository: SpotifyAuthRepository
    
    public init(authRepository: SpotifyAuthRepository) {
        self.authRepository = authRepository
    }
    
    public func execute() async throws -> (name: String, imageURL: URL?) {
        return try await authRepository.fetchUserProfile()
    }
}
