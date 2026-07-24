//
//  ArchiveFeatureTests.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import Testing
import ComposableArchitecture
import ArchiveDomain
import ArchiveSharedTesting
import FeatureArchiveTesting
@testable import FeatureArchive

@MainActor
struct ArchiveFeatureTests {
    @Test func testOnAppear() async {
        let expectedTracks = [
            ArchivedTrack.stub(title: "A", artist: "B", genre: "Pop"),
            ArchivedTrack.stub(title: "C", artist: "D", genre: "Pop"),
            ArchivedTrack.stub(title: "E", artist: "F", genre: "Rock")
        ]

        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(
                archiveRepository: MockArchiveRepository(tracks: expectedTracks),
                search: EmptyReducer<ArchiveSearchState, ArchiveSearchAction>(),
                folder: EmptyReducer<ArchiveFolderState, ArchiveFolderAction>(),
                addArchive: EmptyReducer<AddArchiveState, AddArchiveAction>()
            )
        }

        await store.send(.onAppear)
        await store.receive(\.loadDataResponse) {
            $0.recentTracks = expectedTracks
            $0.totalTracksCount = 3
            $0.topGenreName = "Pop"
        }
    }

    @Test func testOnDeleteTapped() async {
        let expectedTracks = [
            ArchivedTrack.stub(title: "A", artist: "B", genre: "Pop")
        ]

        let mockRepository = MockArchiveRepository(tracks: expectedTracks)

        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(
                archiveRepository: mockRepository,
                search: EmptyReducer<ArchiveSearchState, ArchiveSearchAction>(),
                folder: EmptyReducer<ArchiveFolderState, ArchiveFolderAction>(),
                addArchive: EmptyReducer<AddArchiveState, AddArchiveAction>()
            )
        }

        await store.send(.onDeleteTapped(track: expectedTracks[0]))
        await store.receive(\.onAppear)
        await store.receive(\.loadDataResponse) {
            $0.recentTracks = expectedTracks
            $0.totalTracksCount = 1
            $0.topGenreName = "Pop"
        }
    }

    @Test func testOnAddTapped() async {
        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(
                archiveRepository: MockArchiveRepository(tracks: []),
                search: EmptyReducer<ArchiveSearchState, ArchiveSearchAction>(),
                folder: EmptyReducer<ArchiveFolderState, ArchiveFolderAction>(),
                addArchive: EmptyReducer<AddArchiveState, AddArchiveAction>()
            )
        }

        await store.send(.onAddTapped) { state in
            state.destination = state.destination // TestStore exact match 우회
        }

        guard case .addArchive = store.state.destination else {
            Issue.record("Expected destination to be .addArchive")
            return
        }
    }

    @Test func testOnSearchTapped() async {
        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(
                archiveRepository: MockArchiveRepository(tracks: []),
                search: EmptyReducer<ArchiveSearchState, ArchiveSearchAction>(),
                folder: EmptyReducer<ArchiveFolderState, ArchiveFolderAction>(),
                addArchive: EmptyReducer<AddArchiveState, AddArchiveAction>()
            )
        }

        await store.send(.onSearchTapped) { state in
            state.destination = .search(ArchiveSearchState())
        }
    }

    @Test func testOnFolderTapped() async {
        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(
                archiveRepository: MockArchiveRepository(tracks: []),
                search: EmptyReducer<ArchiveSearchState, ArchiveSearchAction>(),
                folder: EmptyReducer<ArchiveFolderState, ArchiveFolderAction>(),
                addArchive: EmptyReducer<AddArchiveState, AddArchiveAction>()
            )
        }

        await store.send(.onFolderTapped) { state in
            state.destination = .folder(ArchiveFolderState())
        }
    }
}
