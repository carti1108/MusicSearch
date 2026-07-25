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
            ArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: expectedTracks)
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
            ArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = mockRepository
        }

        await store.send(.onDeleteTapped(track: expectedTracks[0]))
        await store.receive(\.onAppear)
        await store.receive(\.loadDataResponse) {
            $0.recentTracks = []
            $0.totalTracksCount = 0
            $0.topGenreName = "없음"
        }
    }

    @Test func testOnAddTapped() async {
        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: [])
        }

        await store.send(.onAddTapped) { state in
            state.destination = .addArchive(AddArchiveState())
        }
    }

    @Test func testOnSearchTapped() async {
        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: [])
        }

        await store.send(.onSearchTapped) { state in
            state.path.append(.search(ArchiveSearchState()))
        }
    }

    @Test func testOnFolderTapped() async {
        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: [])
        }

        await store.send(.onFolderTapped) { state in
            state.path.append(.folder(ArchiveFolderState()))
        }
    }
}
