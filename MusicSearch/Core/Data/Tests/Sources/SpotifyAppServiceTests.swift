//
//  SpotifyAppServiceTests.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Testing
import Foundation
@testable import MSData
@testable import MSDomain
import NetworkLayer

struct MockNetworkManager: NetworkRequesting, @unchecked Sendable {
    var errorToThrow: Error?
    var responseToReturn: Any?
    
    func perform<T: Decodable, E: Requestable>(with endpoint: E, as type: T.Type) async throws -> T {
        if let error = errorToThrow {
            throw error
        }
        if let response = responseToReturn as? T {
            return response
        }
        fatalError("Not implemented for this type")
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
            authService: mockAuth
        )
        
        let track = Track(title: "Hysteria", artist: "Muse", imageURL: nil)
        
        // When
        let fallbackURL = await repository.fetchDeepLink(for: track)
        
        // Then
        #expect(fallbackURL != nil)
        #expect(fallbackURL?.absoluteString.contains("search/Hysteria%20Muse") == true)
        #expect(fallbackURL?.host == "open.spotify.com")
    }
    
    @Test("정상 응답 시 트랙 딥링크를 성공적으로 반환하는가")
    func testFetchTrackDeepLinkSuccess() async throws {
        // Given
        let mockDTO = SpotifyTrackDTO(
            id: "1", name: "Hysteria", uri: "spotify:track:1",
            artists: [SpotifyArtistDTO(id: "2", name: "Muse", uri: nil, external_urls: nil)],
            album: nil,
            external_urls: SpotifyExternalURLs(spotify: "https://open.spotify.com/track/1")
        )
        let response = SpotifyTrackSearchResponse(tracks: SpotifyItems(items: [mockDTO], total: 1))
        let mockNetwork = MockNetworkManager(responseToReturn: response)
        let mockAuth = MockMusicAuthService()
        let repository = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        let track = Track(title: "Hysteria", artist: "Muse", imageURL: nil)
        
        // When
        let url = await repository.fetchDeepLink(for: track)
        
        // Then
        #expect(url?.absoluteString == "https://open.spotify.com/track/1")
    }
    
    @Test("정상 응답 시 아티스트 딥링크를 성공적으로 반환하는가")
    func testFetchArtistDeepLinkSuccess() async throws {
        // Given
        let mockDTO = SpotifyArtistDTO(
            id: "2", name: "Muse", uri: "spotify:artist:2",
            external_urls: SpotifyExternalURLs(spotify: "https://open.spotify.com/artist/2")
        )
        let response = SpotifyArtistSearchResponse(artists: SpotifyItems(items: [mockDTO], total: 1))
        let mockNetwork = MockNetworkManager(responseToReturn: response)
        let mockAuth = MockMusicAuthService()
        let repository = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let url = await repository.fetchDeepLink(for: "Muse")
        
        // Then
        #expect(url?.absoluteString == "https://open.spotify.com/artist/2")
    }
    
    @Test("external_urls가 없을 경우 uri를 기반으로 Web URL을 생성하는가")
    func testFallbackToURIConversion() async throws {
        // Given
        let mockDTO = SpotifyArtistDTO(
            id: "2", name: "Muse", uri: "spotify:artist:2",
            external_urls: nil
        )
        let response = SpotifyArtistSearchResponse(artists: SpotifyItems(items: [mockDTO], total: 1))
        let mockNetwork = MockNetworkManager(responseToReturn: response)
        let mockAuth = MockMusicAuthService()
        let repository = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let url = await repository.fetchDeepLink(for: "Muse")
        
        // Then
        #expect(url?.absoluteString == "https://open.spotify.com/artist/2")
    }
    
    @Test("Spotify Tracks 검색을 성공적으로 수행하는가")
    func testSearchSpotifyTracks() async throws {
        // Given
        let mockDTO = SpotifyTrackDTO(
            id: "1", name: "Hysteria", uri: "spotify:track:1",
            artists: [SpotifyArtistDTO(id: "2", name: "Muse", uri: nil, external_urls: nil)],
            album: nil, external_urls: nil
        )
        let response = SpotifyTrackSearchResponse(tracks: SpotifyItems(items: [mockDTO], total: 100))
        let mockNetwork = MockNetworkManager(responseToReturn: response)
        let mockAuth = MockMusicAuthService()
        let repository = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let result = try await repository.searchSpotifyTracks(query: "Hysteria", limit: 20, offset: 0)
        
        // Then
        #expect(result.totalResults == 100)
        #expect(result.tracks.count == 1)
        #expect(result.tracks.first?.title == "Hysteria")
    }
}
