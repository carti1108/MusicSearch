import Testing
import Foundation
@testable import MSInfrastructure
@testable import MSDomain
import MSTesting

struct SpotifyArtistImageServiceTests {
    
    @Test("정상 응답 시 아티스트 이미지 URL을 성공적으로 반환하는가")
    func testFetchImageURLSuccess() async throws {
        // Given
        let mockTokenResponse = SpotifyTokenResponse(access_token: "client-token", token_type: "Bearer", expires_in: 3600, refresh_token: nil)
        let mockArtistDTO = SpotifyArtistImageItemDTO(
            name: "artist1",
            images: [
                SpotifyImageDTO(url: "https://example.com/extralarge.png", height: 640, width: 640),
                SpotifyImageDTO(url: "https://example.com/small.png", height: 160, width: 160)
            ]
        )
        let mockSearchResponse = SpotifyArtistImageSearchResponseDTO(
            artists: SpotifyArtistImageItemsDTO(items: [mockArtistDTO])
        )
        
        UserDefaults.standard.set("client-token", forKey: "SpotifyClientToken")
        UserDefaults.standard.set(Date().addingTimeInterval(3600), forKey: "SpotifyClientTokenExpiry")
        defer {
            UserDefaults.standard.removeObject(forKey: "SpotifyClientToken")
            UserDefaults.standard.removeObject(forKey: "SpotifyClientTokenExpiry")
        }
        
        let mockNetwork = MockNetworkManager(responseToReturn: mockSearchResponse)
        let mockAuth = MockMusicAuthService()
        let sut = SpotifyArtistImageService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let url = try await sut.fetchImageURL(for: "Muse")
        
        // Then
        #expect(url?.absoluteString == "https://example.com/extralarge.png")
    }

    @Test("검색된 아티스트가 없을 때 nil을 반환하는가")
    func testFetchImageURLEmpty() async throws {
        // Given
        let mockSearchResponse = SpotifyArtistImageSearchResponseDTO(
            artists: SpotifyArtistImageItemsDTO(items: [])
        )
        
        UserDefaults.standard.set("client-token", forKey: "SpotifyClientToken")
        UserDefaults.standard.set(Date().addingTimeInterval(3600), forKey: "SpotifyClientTokenExpiry")
        
        let mockNetwork = MockNetworkManager(responseToReturn: mockSearchResponse)
        let mockAuth = MockMusicAuthService()
        let sut = SpotifyArtistImageService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let url = try await sut.fetchImageURL(for: "UnknownArtist123")
        
        // Then
        #expect(url == nil)
    }
}
