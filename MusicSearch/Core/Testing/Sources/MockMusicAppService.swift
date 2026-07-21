import Foundation
@testable import MSDomain

public final class MockMusicAppService: MusicAppService, @unchecked Sendable {
    public var fetchDeepLinkForTrackResult: URL?
    public var fetchDeepLinkForArtistResult: URL?
    public var searchTracksResult: (tracks: [Track], totalResults: Int) = ([], 0)
    public var searchTracksError: Error?

    public init() {}

    public func fetchDeepLink(for track: Track) async -> URL? {
        return fetchDeepLinkForTrackResult
    }

    public func fetchDeepLink(for artist: String) async -> URL? {
        return fetchDeepLinkForArtistResult
    }

    public func searchTracks(query: String, limit: Int, offset: Int) async throws -> (tracks: [Track], totalResults: Int) {
        if let error = searchTracksError {
            throw error
        }
        return searchTracksResult
    }
}
