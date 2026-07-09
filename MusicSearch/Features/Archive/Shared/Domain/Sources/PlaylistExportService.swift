import Foundation

public protocol PlaylistExportService: Sendable {
    func getUserProfile(token: String) async throws -> String
    func createPlaylist(userId: String, name: String, token: String) async throws -> String
    func searchTrack(title: String, artist: String, token: String) async throws -> String?
    func addItemsToPlaylist(playlistId: String, uris: [String], token: String) async throws
}
