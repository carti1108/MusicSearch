import Foundation

public protocol MusicAuthService: Sendable {
    func getAccessToken() -> String?
    func getClientCredentialsToken() async throws -> String
    func authorize() async throws
    func disconnect()
    func fetchUserProfile() async throws -> (name: String, imageURL: URL?)
}
