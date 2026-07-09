import Foundation
import UIKit
import Combine
import MicroRIBs
import MSDomain
import ArchiveDomain
import TrackSearchDomain
import TrackSearchDomain
import FeatureAddArchive
import FeatureAddArchiveInterface
import FeatureArchiveTrackSearchInterface

@MainActor
final class ExampleAppComponent: AddArchiveDependency {
    var archiveRepository: ArchiveRepository {
        MockArchiveRepository()
    }
    var searchTracksUseCase: SearchTracksUseCase {
        MockSearchTracksUseCase()
    }

    var archiveTrackSearchBuilder: ArchiveTrackSearchBuildable {
        MockArchiveTrackSearchBuilder()
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



final class MockArchiveTrackSearchBuilder: ArchiveTrackSearchBuildable {
    func build(withListener listener: FeatureArchiveTrackSearchInterface.ArchiveTrackSearchListener) -> FeatureArchiveTrackSearchInterface.ArchiveTrackSearchRouting {
        fatalError()
    }
}
