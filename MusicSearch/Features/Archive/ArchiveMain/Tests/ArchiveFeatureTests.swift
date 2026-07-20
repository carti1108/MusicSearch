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
            ArchiveFeature(archiveRepository: MockArchiveRepository(tracks: expectedTracks)) { _ in }
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

    @Test func testRoutingActions() async {
        var delegatedActions: [ArchiveFeature.DelegateAction] = []

        let store = TestStore(initialState: ArchiveFeature.State()) {
            ArchiveFeature(archiveRepository: MockArchiveRepository(tracks: [])) { action in
                delegatedActions.append(action)
            }
        }

        await store.send(.onAddTapped)
        #expect(delegatedActions == [.routeToAddArchive])

        await store.send(.onSearchTapped)
        #expect(delegatedActions == [.routeToAddArchive, .routeToSearch])

        await store.send(.onFolderTapped)
        #expect(delegatedActions == [.routeToAddArchive, .routeToSearch, .routeToFolder])
    }
}

