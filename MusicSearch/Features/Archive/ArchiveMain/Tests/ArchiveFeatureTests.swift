import XCTest
import ComposableArchitecture
import ArchiveDomain
@testable import FeatureArchive

@MainActor
final class ArchiveFeatureTests: XCTestCase {
    func testOnAppear() async {
        let expectedTracks = [
            ArchivedTrack(id: "1", trackID: "t1", title: "A", artist: "B", coverImageData: nil, genre: "Pop", tags: [], memo: "", createdAt: Date(), updatedAt: Date()),
            ArchivedTrack(id: "2", trackID: "t2", title: "C", artist: "D", coverImageData: nil, genre: "Pop", tags: [], memo: "", createdAt: Date(), updatedAt: Date()),
            ArchivedTrack(id: "3", trackID: "t3", title: "E", artist: "F", coverImageData: nil, genre: "Rock", tags: [], memo: "", createdAt: Date(), updatedAt: Date())
        ]

        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(archiveRepository: MockArchiveRepository(tracks: expectedTracks)) { _ in }
        }

        await store.send(.onAppear)
        await store.receive(\.loadDataResponse) {
            $0.recentTracks = expectedTracks
            $0.totalTracksCount = 3
            $0.topGenreName = "Pop"
        }
    }

    func testOnDeleteTapped() async {
        let expectedTracks = [
            ArchivedTrack(id: "1", trackID: "t1", title: "A", artist: "B", coverImageData: nil, genre: "Pop", tags: [], memo: "", createdAt: Date(), updatedAt: Date())
        ]

        let mockRepository = MockArchiveRepository(tracks: expectedTracks)

        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(archiveRepository: mockRepository) { _ in }
        }

        await store.send(.onDeleteTapped(track: expectedTracks[0]))
        await store.receive(\.onAppear)
        await store.receive(\.loadDataResponse) {
            $0.recentTracks = expectedTracks
            $0.totalTracksCount = 1
            $0.topGenreName = "Pop"
        }
    }

    func testRoutingActions() async {
        var delegatedActions: [ArchiveFeature.DelegateAction] = []

        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(archiveRepository: MockArchiveRepository(tracks: [])) { action in
                delegatedActions.append(action)
            }
        }

        await store.send(.onAddTapped)
        XCTAssertEqual(delegatedActions, [.routeToAddArchive])

        await store.send(.onSearchTapped)
        XCTAssertEqual(delegatedActions, [.routeToAddArchive, .routeToSearch])

        await store.send(.onFolderTapped)
        XCTAssertEqual(delegatedActions, [.routeToAddArchive, .routeToSearch, .routeToFolder])
    }
}

final class MockArchiveRepository: ArchiveRepository {
    var tracks: [ArchivedTrack]
    init(tracks: [ArchivedTrack]) { self.tracks = tracks }

    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return tracks }
    func saveArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
    func fetchFolders() async throws -> [FolderItem] { return [] }
    func saveFolder(_ folder: FolderItem) async throws { }
    func deleteFolder(id: String) async throws { }
    func addTrackToFolder(trackID: String, folderID: String) async throws { }
    func removeTrackFromFolder(trackID: String, folderID: String) async throws { }
}
