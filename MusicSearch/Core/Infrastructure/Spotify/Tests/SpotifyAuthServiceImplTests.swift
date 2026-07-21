import Testing
import Foundation
@testable import MSInfrastructure
@testable import MSDomain
import MSUtil
import MSTesting

@Suite(.serialized)
struct SpotifyAuthServiceImplTests {
    
    init() {
        KeychainManager.shared.isTesting = true
    }
    
    @Test("네트워크 정상 응답 시 fetchUserProfile이 올바른 유저 정보를 반환하는가")
    func testFetchUserProfileSuccess() async throws {
        // Given
        let mockResponse = SpotifyUserProfileResponse(
            display_name: "TestUser",
            id: "user123",
            images: [SpotifyImage(url: "https://example.com/test.png", height: nil, width: nil)]
        )
        let mockNetwork = MockNetworkManager(responseToReturn: mockResponse)
        let sut = SpotifyAuthServiceImpl(networkManager: mockNetwork)
        
        _ = KeychainManager.shared.saveString("dummy-token", forKey: "SpotifyAccessToken")
        defer { _ = KeychainManager.shared.delete(forKey: "SpotifyAccessToken") }
        
        // When
        let result = try await sut.fetchUserProfile()
        
        // Then
        #expect(result.name == "TestUser")
        #expect(result.imageURL?.absoluteString == "https://example.com/test.png")
    }

    @Test("저장된 액세스 토큰이 없을 때 fetchUserProfile이 에러를 던지는가")
    func testFetchUserProfileWithoutToken() async {
        // Given
        let mockNetwork = MockNetworkManager()
        let sut = SpotifyAuthServiceImpl(networkManager: mockNetwork)
        
        _ = KeychainManager.shared.delete(forKey: "SpotifyAccessToken")
        
        // When & Then
        await #expect(throws: URLError.self) {
            _ = try await sut.fetchUserProfile()
        }
    }

    @Test("네트워크 에러 발생 시 fetchUserProfile이 해당 에러를 던지는가")
    func testFetchUserProfileNetworkFailure() async {
        // Given
        struct TestError: Error {}
        let mockNetwork = MockNetworkManager(errorToThrow: TestError())
        let sut = SpotifyAuthServiceImpl(networkManager: mockNetwork)
        
        _ = KeychainManager.shared.saveString("dummy-token", forKey: "SpotifyAccessToken")
        defer { _ = KeychainManager.shared.delete(forKey: "SpotifyAccessToken") }
        
        // When & Then
        await #expect(throws: TestError.self) {
            _ = try await sut.fetchUserProfile()
        }
    }
    
    @Test("클라이언트 크리덴셜 토큰을 성공적으로 발급 및 캐싱하는가")
    func testGetClientCredentialsToken() async throws {
        // Given
        let mockResponse = SpotifyTokenResponse(
            access_token: "new-client-token",
            token_type: "Bearer",
            expires_in: 3600,
            refresh_token: nil
        )
        let mockNetwork = MockNetworkManager(responseToReturn: mockResponse)
        let sut = SpotifyAuthServiceImpl(networkManager: mockNetwork)
        
        UserDefaults.standard.removeObject(forKey: "SpotifyClientToken")
        UserDefaults.standard.removeObject(forKey: "SpotifyClientTokenExpiry")
        
        // When
        let token = try await sut.getClientCredentialsToken()
        
        // Then
        #expect(token == "new-client-token")
        #expect(UserDefaults.standard.string(forKey: "SpotifyClientToken") == "new-client-token")
    }
}
