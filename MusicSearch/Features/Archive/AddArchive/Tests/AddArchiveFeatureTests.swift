//
//  AddArchiveFeatureTests.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ComposableArchitecture
import Testing
import ArchiveDomain
import TrackSearchDomain
import MSDomain
import FeatureArchiveTrackSearchInterface
import ArchiveSharedTesting
import FeatureTrackSearchTesting
@testable import FeatureAddArchive

@MainActor
struct AddArchiveFeatureTests {

    @Test func testMemoInput() async {
        let store = TestStore(initialState: AddArchiveFeature.State()) {
            AddArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: [])
            $0.searchTracksUseCase = MockSearchTracksUseCase()
        }

        await store.send(.binding(.set(\.memo, "Great track"))) {
            $0.memo = "Great track"
        }
    }

    @Test func testCloseTapped() async {
        let store = TestStore(initialState: AddArchiveFeature.State()) {
            AddArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: [])
            $0.searchTracksUseCase = MockSearchTracksUseCase()
        }

        await store.send(.closeButtonTapped)
        await store.receive(\.delegate.didCloseAddArchive)
    }
}

