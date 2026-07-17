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
    let scenario: DemoScenario

    init(scenario: DemoScenario) {
        self.scenario = scenario
    }

    var archiveRepository: ArchiveRepository {
        MockArchiveRepository(scenario: scenario)
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
    let scenario: DemoScenario
    
    init(scenario: DemoScenario = .success) {
        self.scenario = scenario
    }
    
    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return [] }
    
    func addArchivedTrack(_ track: ArchivedTrack) async throws {
        switch scenario {
        case .error:
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "아카이브 추가 실패"])
        case .delayed:
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        default:
            break
        }
    }
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
