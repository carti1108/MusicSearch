import Foundation
import Testing
import ComposableArchitecture
import ArchiveDomain
import ArchiveSharedTesting
import FeatureArchiveSearchTesting
@testable import FeatureArchiveSearch

@MainActor
struct ArchiveSearchFeatureTests {
    @Test func testOnAppear() async {
        let expectedTracks = [
            ArchivedTrack.stub(platformIDs: ["apple": "t1"], title: "A", artist: "B", genre: "Pop")
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

    @Test func testSearchTextFiltering() async {
        let allTracks = [
            ArchivedTrack.stub(platformIDs: ["apple": "t1"], title: "Apple", artist: "B", genre: "Pop"),
            ArchivedTrack.stub(platformIDs: ["apple": "t2"], title: "Banana", artist: "D", genre: "Rock")
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

    @Test func testRecentSearches() async {
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

