import Foundation
import ArchiveDomain

public final class MockExportPlaylistUseCase: ExportPlaylistUseCase, @unchecked Sendable {
    public var executeCallCount = 0
    public var lastTracks: [ArchivedTrack]?
    public var lastPlaylistName: String?
    public var executeResult: [ExportProgress] = []

    public init() {}

    public func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        executeCallCount += 1
        lastTracks = tracks
        lastPlaylistName = playlistName

        let (stream, continuation) = AsyncStream.makeStream(of: ExportProgress.self)
        Task {
            for progress in executeResult {
                continuation.yield(progress)
            }
            continuation.finish()
        }
        return stream
    }
}
