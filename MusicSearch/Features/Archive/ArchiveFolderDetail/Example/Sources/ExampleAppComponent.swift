import Foundation
import UIKit
import MicroRIBs
import MSDomain
import ArchiveDomain
import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailInterface

@MainActor
final class ExampleAppComponent: ArchiveFolderDetailDependency {
    var archiveRepository: ArchiveRepository {
        MockArchiveRepository()
    }

    var exportToSpotifyUseCase: ExportToSpotifyUseCase {
        MockExportToSpotifyUseCase()
    }

    var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
        MockManageSpotifyAuthUseCase()
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] {
        return [
            ArchivedTrack(id: UUID(), title: "Folder Track", artist: "Artist", genre: "Pop", label: "", rating: 0)
        ]
    }

    func addArchivedTrack(_ track: ArchivedTrack) async throws { }

    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }

    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockExportToSpotifyUseCase: ExportToSpotifyUseCase {
    func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        return AsyncStream { continuation in
            continuation.yield(ExportProgress(totalCount: 1, currentCount: 1, failedTracks: [], isComplete: true))
            continuation.finish()
        }
    }
}

final class MockManageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
    func getAccessToken() -> String? { return "token" }
    func authorize() async throws { }
    func disconnect() { }
}
