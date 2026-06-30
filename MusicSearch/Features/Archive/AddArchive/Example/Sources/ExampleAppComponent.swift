import Foundation
import UIKit
import Combine
import MicroRIBs
import MSDomain
import ArchiveDomain
import TrackSearchDomain
import FeatureAddArchive
import FeatureAddArchiveInterface

@MainActor
final class ExampleAppComponent: AddArchiveDependency {
    var archiveRepository: ArchiveRepository {
        MockArchiveRepository()
    }
    var searchTracksUseCase: SearchTracksUseCase {
        MockSearchTracksUseCase()
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return [] }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockSearchTracksUseCase: SearchTracksUseCase {
    func execute(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
        return ([], 0)
    }
}
