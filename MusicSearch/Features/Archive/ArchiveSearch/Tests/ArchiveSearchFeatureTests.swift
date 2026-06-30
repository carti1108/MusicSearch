import XCTest
import ComposableArchitecture
import ArchiveDomain
@testable import FeatureArchiveSearch

@MainActor
final class ArchiveSearchFeatureTests: XCTestCase {
    func testOnAppear() async {
        let expectedTracks = [
            ArchivedTrack(id: "1", trackID: "t1", title: "A", artist: "B", coverImageData: nil, genre: "Pop", tags: [], memo: "", createdAt: Date(), updatedAt: Date())
        ]

        let store = TestStore(initialState: ArchiveSearchFeature.State()) {
            ArchiveSearchFeature(archiveRepository: MockArchiveRepository(tracks: expectedTracks))
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.onAppear)
        await store.receive(\.tracksLoaded.success) {
            $0.allTracks = expectedTracks
        }
    }

    func testSearchTextFiltering() async {
        let allTracks = [
            ArchivedTrack(id: "1", trackID: "t1", title: "Apple", artist: "B", coverImageData: nil, genre: "Pop", tags: [], memo: "", createdAt: Date(), updatedAt: Date()),
            ArchivedTrack(id: "2", trackID: "t2", title: "Banana", artist: "D", coverImageData: nil, genre: "Rock", tags: [], memo: "", createdAt: Date(), updatedAt: Date())
        ]

        var state = ArchiveSearchFeature.State()
        state.allTracks = allTracks

        let store = TestStore(initialState: state) {
            ArchiveSearchFeature(archiveRepository: MockArchiveRepository(tracks: allTracks))
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
        }

        await store.send(.binding(.set(\.searchText, "app"))) {
            $0.searchText = "app"
        }

        await store.receive(\.tracksLoaded.success) {
            $0.recommendedTracks = [allTracks[0]]
        }

        await store.send(.binding(.set(\.searchText, ""))) {
            $0.searchText = ""
            $0.recommendedTracks = []
        }
    }

    func testRecentSearches() async {
        var state = ArchiveSearchFeature.State()
        state.recentSearches = ["term1", "term2"]

        let store = TestStore(initialState: state) {
            ArchiveSearchFeature(archiveRepository: MockArchiveRepository(tracks: []))
        }

        await store.send(.removeRecentSearch("term1")) {
            $0.recentSearches = ["term2"]
        }

        await store.send(.clearRecentSearches) {
            $0.recentSearches = []
        }
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
