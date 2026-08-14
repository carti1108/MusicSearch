//
//  FeatureArchiveFolderDetailTests.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import Testing
import ComposableArchitecture
import ArchiveDomain
import ArchiveSharedTesting
import FeatureArchiveFolderDetailTesting
import MSDomain
import MSTesting
@testable import FeatureArchiveFolderDetail

@MainActor
struct FeatureArchiveFolderDetailTests {
    @Test func testOnAppear() async {
        let folder = FolderItem(title: "My Folder", subtitle: "0", type: .custom)
        let tracks = [
            ArchivedTrack(id: UUID(), title: "A", artist: "B", genres: ["Pop"], label: "", rating: 0)
        ]

        let store = TestStore(initialState: ArchiveFolderDetailFeature.State(folderItem: folder)) {
            ArchiveFolderDetailFeature()
        } withDependencies: {
            $0.archiveRepository = MockArchiveRepository(tracks: tracks)
            $0.exportPlaylistUseCase = MockExportPlaylistUseCase()
            $0.getMusicAccessTokenUseCase = MockGetMusicAccessTokenUseCase()
            $0.authorizeMusicUseCase = MockAuthorizeMusicUseCase()
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

