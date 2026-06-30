import Foundation

public protocol ExportToSpotifyUseCase: Sendable {
    func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress>
}
