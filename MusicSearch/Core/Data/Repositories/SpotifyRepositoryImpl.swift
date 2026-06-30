import Foundation
import ArchiveDomain
import NetworkLayer

public final class SpotifyRepositoryImpl: SpotifyRepository {
    private let networkManager: NetworkRequesting

    public init(networkManager: NetworkRequesting) {
        self.networkManager = networkManager
    }

    public func getUserProfile(token: String) async throws -> String {
        let config = DefaultSpotifyAPIConfiguration()
        let meApi = SpotifyAPI.me(token: token, config: config)
        let userProfile = try await networkManager.perform(with: meApi, as: SpotifyUserProfileResponse.self)
        return userProfile.id
    }

    public func createPlaylist(userId: String, name: String, token: String) async throws -> String {
        let config = DefaultSpotifyAPIConfiguration()
        let createApi = SpotifyAPI.createPlaylist(userId: userId, name: name, token: token, config: config)
        let playlistResponse = try await networkManager.perform(with: createApi, as: SpotifyPlaylistResponse.self)
        return playlistResponse.id
    }

    public func searchTrack(title: String, artist: String, token: String) async throws -> String? {
        let config = DefaultSpotifyAPIConfiguration()
        let query = "track:\(title) artist:\(artist)"
        let searchApi = SpotifyAPI.search(query: query, type: "track", limit: 1, offset: 0, token: token, config: config)
        let searchResponse = try await networkManager.perform(with: searchApi, as: SpotifyTrackSearchResponse.self)
        return searchResponse.tracks.items.first?.uri
    }

    public func addItemsToPlaylist(playlistId: String, uris: [String], token: String) async throws {
        let config = DefaultSpotifyAPIConfiguration()
        let addApi = SpotifyAPI.addItemsToPlaylist(playlistId: playlistId, uris: uris, token: token, config: config)
        _ = try await networkManager.perform(with: addApi, as: SpotifySnapshotResponse.self)
    }
}
