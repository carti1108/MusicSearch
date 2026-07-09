import Foundation

public protocol FetchUserProfileUseCase: Sendable {
    func execute() async throws -> (name: String, imageURL: URL?)
}

public final class FetchUserProfileUseCaseImpl: FetchUserProfileUseCase {
    private let authService: MusicAuthService

    public init(authService: MusicAuthService) {
        self.authService = authService
    }

    public func execute() async throws -> (name: String, imageURL: URL?) {
        return try await authService.fetchUserProfile()
    }
}
