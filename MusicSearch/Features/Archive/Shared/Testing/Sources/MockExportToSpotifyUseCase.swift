import Foundation
import ArchiveDomain

public final class MockExportToSpotifyUseCase: ExportToSpotifyUseCase, @unchecked Sendable {
    public var executeCallCount = 0
    public var lastTracks: [ArchivedTrack]?
    public var lastPlaylistName: String?
    public var executeResult: [ExportProgress] = []
    
    public init() {}
    
    public func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        executeCallCount += 1
        lastTracks = tracks
        lastPlaylistName = playlistName
        
        return AsyncStream { continuation in
            Task {
                for progress in executeResult {
                    continuation.yield(progress)
                }
                continuation.finish()
            }
        }
    }
}
