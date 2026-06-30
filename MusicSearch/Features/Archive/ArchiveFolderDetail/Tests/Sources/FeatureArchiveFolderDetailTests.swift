import XCTest
import ComposableArchitecture
import ArchiveDomain
import MSDomain
@testable import FeatureArchiveFolderDetail

@MainActor
final class FeatureArchiveFolderDetailTests: XCTestCase {
    func testOnAppear() async {
        let folder = FolderItem(title: "My Folder", subtitle: "0", type: .custom)
        let tracks = [
            ArchivedTrack(id: UUID(), title: "A", artist: "B", genre: "Pop", label: "", rating: 0)
        ]
        
        let store = TestStore(initialState: ArchiveFolderDetailFeature.State(folderItem: folder)) {
            ArchiveFolderDetailFeature(archiveRepository: MockArchiveRepository(tracks: tracks), exportToSpotifyUseCase: MockExport(), manageSpotifyAuthUseCase: MockAuth(), onDelegate: { _ in })
        }
        
        await store.send(ArchiveFolderDetailFeature.Action.onAppear)
        await store.receive({
            if case .loadDataResponse = $0 { return true }
            return false
        }) {
            $0.tracks = tracks
        }
    }
}

final class MockArchiveRepository: ArchiveRepository, @unchecked Sendable {
    var tracks: [ArchivedTrack]
    init(tracks: [ArchivedTrack]) { self.tracks = tracks }
    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return tracks }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}
final class MockExport: ExportToSpotifyUseCase {
    func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        return AsyncStream { continuation in
            continuation.yield(ExportProgress(totalCount: 1, currentCount: 1, failedTracks: [], isComplete: true))
            continuation.finish()
        }
    }
}
final class MockAuth: ManageSpotifyAuthUseCase {
    func getAccessToken() -> String? { return "token" }
    func authorize() async throws {}
    func disconnect() {}
}
