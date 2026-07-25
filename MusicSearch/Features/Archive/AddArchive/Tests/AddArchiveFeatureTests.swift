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
@testable import FeatureAddArchive

@MainActor
struct AddArchiveFeatureTests {

    @Test func testMemoInput() async {
        let store = TestStore(initialState: AddArchiveFeature.State()) {
            AddArchiveFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository()
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
            $0.archiveRepository = MockArchiveRepository()
            $0.searchTracksUseCase = MockSearchTracksUseCase()
        }

        await store.send(.closeButtonTapped)
        await store.receive(\.delegate.didCloseAddArchive)
    }
}

final class MockArchiveRepository: ArchiveRepository, @unchecked Sendable {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return [] }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockSearchTracksUseCase: SearchTracksUseCase, @unchecked Sendable {
    func execute(query: String, limit: Int, offset: Int) async throws -> (tracks: [Track], totalResults: Int) {
        return ([], 0)
    }
}
