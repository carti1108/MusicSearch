import Testing
import Foundation
@testable import MSData
@testable import MSDomain
import NetworkLayer

struct MockNetworkManager: NetworkRequesting {
    var errorToThrow: Error?
    
    func perform<T: Decodable, E: Requestable>(with endpoint: E, as type: T.Type) async throws -> T {
        if let error = errorToThrow {
            throw error
        }
        fatalError("Not implemented for success case in this mock")
    }
}

struct MockMusicAuthService: MusicAuthService {
    var token: String? = "mock-token"
    var errorToThrow: Error?
    
    func getAccessToken() -> String? {
        return token
    }
    
    func setAccessToken(_ token: String, expiresIn: Int) {}
    func clearTokens() {}
    
    func getClientCredentialsToken() async throws -> String {
        if let error = errorToThrow {
            throw error
        }
        return "mock-token"
    }
    
    func getAuthorizationURL() -> URL? { return nil }
    func requestAccessToken(code: String) async throws -> String { return "" }
    func getValidAccessToken() async throws -> String { return "" }
    
    func authorize() async throws {}
    func disconnect() {}
    func fetchUserProfile() async throws -> (name: String, imageURL: URL?) {
        return ("MockUser", nil)
    }
}

@Suite("Spotify App Repository Tests")
struct SpotifyAppServiceTests {
    
    @Test("네트워크 에러 발생 시, OSLog 에러를 출력하고 Fallback Web URL을 반환하는가")
    func testFetchDeepLinkFallback() async throws {
        // Given
        struct MockError: Error {}
        
        let mockNetwork = MockNetworkManager(errorToThrow: MockError())
        let mockAuth = MockMusicAuthService()
        
        let repository = SpotifyAppService(
            networkManager: mockNetwork,
            authRepository: mockAuth
        )
        
        let track = Track(title: "Hysteria", artist: "Muse", imageURL: nil)
        
        // When
        let fallbackURL = await repository.fetchDeepLink(for: track)
        
        // Then
        #expect(fallbackURL != nil)
        #expect(fallbackURL?.absoluteString.contains("search/Hysteria%20Muse") == true)
        #expect(fallbackURL?.host == "open.spotify.com")
    }
}
