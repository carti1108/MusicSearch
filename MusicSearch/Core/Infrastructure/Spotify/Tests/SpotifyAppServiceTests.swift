//
//  SpotifyAppServiceTests.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Testing
import Foundation
@testable import MSInfrastructure
@testable import MSDomain
import NetworkLayer


import MSTesting

struct SpotifyAppServiceTests {
    
    @Test("네트워크 에러 발생 시, OSLog 에러를 출력하고 Fallback Web URL을 반환하는가")
    func testFetchDeepLinkFallback() async throws {
        // Given
        struct MockError: Error {}
        
        let mockNetwork = MockNetworkManager(errorToThrow: MockError())
        let mockAuth = MockMusicAuthService()
        
        let sut = SpotifyAppService(
            networkManager: mockNetwork,
            authService: mockAuth
        )
        
        let track = Track(title: "Hysteria", artist: "Muse", imageURL: nil)
        
        // When
        let fallbackURL = await sut.fetchDeepLink(for: track)
        
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
        let sut = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        let track = Track(title: "Hysteria", artist: "Muse", imageURL: nil)
        
        // When
        let url = await sut.fetchDeepLink(for: track)
        
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
        let sut = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let url = await sut.fetchDeepLink(for: "Muse")
        
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
        let sut = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let url = await sut.fetchDeepLink(for: "Muse")
        
        // Then
        #expect(url?.absoluteString == "https://open.spotify.com/artist/2")
    }
    
    @Test("Tracks 검색을 성공적으로 수행하는가")
    func testSearchTracks() async throws {
        // Given
        let mockDTO = SpotifyTrackDTO(
            id: "1", name: "Hysteria", uri: "spotify:track:1",
            artists: [SpotifyArtistDTO(id: "2", name: "Muse", uri: nil, external_urls: nil)],
            album: nil, external_urls: nil
        )
        let response = SpotifyTrackSearchResponse(tracks: SpotifyItems(items: [mockDTO], total: 100))
        let mockNetwork = MockNetworkManager(responseToReturn: response)
        let mockAuth = MockMusicAuthService()
        let sut = SpotifyAppService(networkManager: mockNetwork, authService: mockAuth)
        
        // When
        let result = try await sut.searchTracks(query: "Hysteria", limit: 20, offset: 0)
        
        // Then
        #expect(result.totalResults == 100)
        #expect(result.tracks.count == 1)
        #expect(result.tracks.first?.title == "Hysteria")
    }
}
