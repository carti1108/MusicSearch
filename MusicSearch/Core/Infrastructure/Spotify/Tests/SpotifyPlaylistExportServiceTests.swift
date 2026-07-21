import Testing
import Foundation
@testable import MSInfrastructure
@testable import MSDomain
import MSTesting

struct SpotifyPlaylistExportServiceTests {
    
    @Test("유저 ID를 성공적으로 가져오는가")
    func testGetUserProfileSuccess() async throws {
        // Given
        let mockResponse = SpotifyUserProfileResponse(
            display_name: "TestUser",
            id: "user123",
            images: nil
        )
        let mockNetwork = MockNetworkManager(responseToReturn: mockResponse)
        let sut = SpotifyPlaylistExportService(networkManager: mockNetwork)
        
        // When
        let userId = try await sut.getUserProfile(token: "token")
        
        // Then
        #expect(userId == "user123")
    }

    @Test("플레이리스트를 성공적으로 생성하고 ID를 반환하는가")
    func testCreatePlaylistSuccess() async throws {
        // Given
        let mockResponse = SpotifyPlaylistResponse(id: "playlist123", uri: "spotify:playlist:123")
        let mockNetwork = MockNetworkManager(responseToReturn: mockResponse)
        let sut = SpotifyPlaylistExportService(networkManager: mockNetwork)
        
        // When
        let playlistId = try await sut.createPlaylist(userId: "user123", name: "My Playlist", token: "token")
        
        // Then
        #expect(playlistId == "playlist123")
    }

    @Test("트랙 검색 시 올바른 URI를 반환하는가")
    func testSearchTrackSuccess() async throws {
        // Given
        let mockDTO = SpotifyTrackDTO(
            id: "1", name: "Hysteria", uri: "spotify:track:123",
            artists: [SpotifyArtistDTO(id: "2", name: "Muse", uri: nil, external_urls: nil)],
            album: nil, external_urls: nil
        )
        let mockResponse = SpotifyTrackSearchResponse(
            tracks: SpotifyItems(items: [mockDTO], total: 1)
        )
        let mockNetwork = MockNetworkManager(responseToReturn: mockResponse)
        let sut = SpotifyPlaylistExportService(networkManager: mockNetwork)
        
        // When
        let uri = try await sut.searchTrack(title: "Hysteria", artist: "Muse", token: "token")
        
        // Then
        #expect(uri == "spotify:track:123")
    }

    @Test("플레이리스트에 아이템 추가 시 에러 없이 성공하는가")
    func testAddItemsToPlaylistSuccess() async throws {
        // Given
        let mockResponse = SpotifySnapshotResponse(snapshot_id: "snapshot123")
        let mockNetwork = MockNetworkManager(responseToReturn: mockResponse)
        let sut = SpotifyPlaylistExportService(networkManager: mockNetwork)
        
        // When & Then
        try await sut.addItemsToPlaylist(playlistId: "playlist123", uris: ["spotify:track:123"], token: "token")
    }
}
