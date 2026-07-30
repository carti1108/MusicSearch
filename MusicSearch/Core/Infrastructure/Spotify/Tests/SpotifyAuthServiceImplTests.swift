import Testing
import Foundation
@testable import MSInfrastructure
@testable import MSDomain
import MSUtil
import MSTesting

@Suite(.serialized)
struct SpotifyAuthServiceImplTests {
    
    @Test("네트워크 정상 응답 시 fetchUserProfile이 올바른 유저 정보를 반환하는가")
    func testFetchUserProfileSuccess() async throws {
        // Given
        let mockResponse = SpotifyUserProfileResponse(
            display_name: "TestUser",
            id: "user123",
            images: [SpotifyImage(url: "https://example.com/test.png", height: nil, width: nil)]
        )
        let mockNetwork = MockNetworkManager(responseToReturn: mockResponse)
        let mockKeychain = MockKeychainService(storage: ["SpotifyAccessToken": "dummy-token"])
        let sut = SpotifyAuthServiceImpl(networkManager: mockNetwork, keychainService: mockKeychain)
        
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
        let mockKeychain = MockKeychainService()
        let sut = SpotifyAuthServiceImpl(networkManager: mockNetwork, keychainService: mockKeychain)
        
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
        let mockKeychain = MockKeychainService(storage: ["SpotifyAccessToken": "dummy-token"])
        let sut = SpotifyAuthServiceImpl(networkManager: mockNetwork, keychainService: mockKeychain)
        
        // When & Then
        await #expect(throws: TestError.self) {
            _ = try await sut.fetchUserProfile()
        }
    }
    
    @Test("웹 인증 및 토큰 교환 성공 시 액세스 및 리프레시 토큰이 정상 저장되는가")
    func testAuthorizeSuccess() async throws {
        // Given
        let tokenResponse = SpotifyTokenResponse(
            access_token: "mock-access-token",
            token_type: "Bearer",
            expires_in: 3600,
            refresh_token: "mock-refresh-token"
        )
        let mockNetwork = MockNetworkManager(responseToReturn: tokenResponse)
        let mockKeychain = MockKeychainService()
        let mockStorage = MockKeyValueStorageService()
        let mockPresenter = MockWebAuthenticationPresenter(
            resultToReturn: .success(URL(string: "musicsearch://callback?code=mock_code")!)
        )
        let sut = SpotifyAuthServiceImpl(
            networkManager: mockNetwork,
            keychainService: mockKeychain,
            webAuthPresenter: mockPresenter,
            keyValueStorage: mockStorage
        )
        
        // When
        try await sut.authorize()
        
        // Then
        #expect(mockKeychain.read(forKey: "SpotifyAccessToken") == "mock-access-token")
        #expect(mockKeychain.read(forKey: "SpotifyRefreshToken") == "mock-refresh-token")
        #expect(mockStorage.object(forKey: "SpotifyTokenExpiry") != nil)
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
        let mockKeychain = MockKeychainService()
        let mockStorage = MockKeyValueStorageService()
        let sut = SpotifyAuthServiceImpl(
            networkManager: mockNetwork,
            keychainService: mockKeychain,
            keyValueStorage: mockStorage
        )
        
        // When
        let token = try await sut.getClientCredentialsToken()
        
        // Then
        #expect(token == "new-client-token")
        #expect(mockStorage.string(forKey: "SpotifyClientToken") == "new-client-token")
    }
}
