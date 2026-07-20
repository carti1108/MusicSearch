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
@testable import FeatureArchiveFolderDetail

@MainActor
struct FeatureArchiveFolderDetailTests {
    @Test func testOnAppear() async {
        let folder = FolderItem(title: "My Folder", subtitle: "0", type: .custom)
        let tracks = [
            ArchivedTrack(id: UUID(), title: "A", artist: "B", genre: "Pop", label: "", rating: 0)
        ]

        let store = TestStore(initialState: ArchiveFolderDetailFeature.State(folderItem: folder)) {
            ArchiveFolderDetailFeature(archiveRepository: MockArchiveRepository(tracks: tracks), exportPlaylistUseCase: MockExport(), getMusicAccessTokenUseCase: MockGetMusicAccessTokenUseCase(), authorizeMusicUseCase: MockAuthorizeMusicUseCase(), onDelegate: { _ in })
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

final class MockExport: ExportPlaylistUseCase {
    func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        let (stream, continuation) = AsyncStream.makeStream(of: ExportProgress.self)
        continuation.yield(ExportProgress(totalCount: 1, currentCount: 1, failedTracks: [], isComplete: true))
        continuation.finish()
        return stream
    }
}

final class MockGetMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
    func execute() -> String? { return "token" }
}
final class MockAuthorizeMusicUseCase: AuthorizeMusicUseCase {
    func execute() async throws {}
}

