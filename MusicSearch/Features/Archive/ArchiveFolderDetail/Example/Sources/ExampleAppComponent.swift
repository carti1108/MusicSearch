//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import UIKit
import MicroRIBs
import MSDomain
import ArchiveDomain
import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailInterface

@MainActor
final class ExampleAppComponent: ArchiveFolderDetailDependency {
    let scenario: DemoScenario

    init(scenario: DemoScenario) {
        self.scenario = scenario
    }

    var archiveRepository: ArchiveRepository {
        MockArchiveRepository(scenario: scenario)
    }

    var exportPlaylistUseCase: ExportPlaylistUseCase {
        MockExportPlaylistUseCase()
    }

    var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
        MockGetMusicAccessTokenUseCase()
    }
    
    var authorizeMusicUseCase: AuthorizeMusicUseCase {
        MockAuthorizeMusicUseCase()
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario = .success) {
        self.scenario = scenario
    }
    
    func fetchArchivedTracks() async throws -> [ArchivedTrack] {
        switch scenario {
        case .success:
            return [
                ArchivedTrack(id: UUID(), title: "Folder Track 1", artist: "Artist 1", genre: "Pop", label: "", rating: 0),
                ArchivedTrack(id: UUID(), title: "Folder Track 2", artist: "Artist 2", genre: "Pop", label: "", rating: 0)
            ]
        case .empty:
            return []
        case .error:
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "네트워크 에러 발생"])
        case .delayed:
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            return [
                ArchivedTrack(id: UUID(), title: "Delayed Track", artist: "Delayed Artist", genre: "Jazz", label: "", rating: 0)
            ]
        }
    }

    func addArchivedTrack(_ track: ArchivedTrack) async throws { }

    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }

    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockExportPlaylistUseCase: ExportPlaylistUseCase {
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
    func execute() async throws { }
}
