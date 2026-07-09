import Foundation

public protocol ExportPlaylistUseCase: Sendable {
    func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress>
}
