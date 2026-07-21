import Foundation
@testable import MSDomain

public final class MockMusicAuthService: MusicAuthService, @unchecked Sendable {
    public var getAccessTokenResult: String?
    public var getClientCredentialsTokenResult: String = "client-token"
    public var authorizeError: Error?
    public var disconnectCalled = false
    public var fetchUserProfileResult: (name: String, imageURL: URL?) = ("User", nil)
    public var fetchUserProfileError: Error?

    public init() {}

    public func getAccessToken() -> String? {
        return getAccessTokenResult
    }

    public func getClientCredentialsToken() async throws -> String {
        return getClientCredentialsTokenResult
    }

    public func authorize() async throws {
        if let error = authorizeError {
            throw error
        }
    }

    public func disconnect() {
        disconnectCalled = true
    }

    public func fetchUserProfile() async throws -> (name: String, imageURL: URL?) {
        if let error = fetchUserProfileError {
            throw error
        }
        return fetchUserProfileResult
    }
}
