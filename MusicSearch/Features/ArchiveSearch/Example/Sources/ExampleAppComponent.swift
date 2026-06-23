import Foundation
import UIKit
import MicroRIBs
import MSDomain
import ArchiveDomain
import FeatureArchiveSearch
import FeatureArchiveSearchInterface

@MainActor
final class ExampleAppComponent: ArchiveSearchDependency {
    var archiveRepository: ArchiveRepository {
        MockArchiveRepository()
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] {
        return [
            ArchivedTrack(id: UUID(), title: "Search Track 1", artist: "Artist 1", genre: "Pop", label: "", rating: 0),
            ArchivedTrack(id: UUID(), title: "Search Track 2", artist: "Artist 2", genre: "Rock", label: "", rating: 0)
        ]
    }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}
