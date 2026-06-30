import ComposableArchitecture
import XCTest
import ArchiveDomain
import TrackSearchDomain
import MSDomain
@testable import FeatureAddArchive

@MainActor
final class AddArchiveFeatureTests: XCTestCase {
    
    func testMemoInput() async {
        let store = TestStore(initialState: AddArchiveFeature.State()) {
            AddArchiveFeature(archiveRepository: MockArchiveRepository(), searchTracksUseCase: MockSearchTracksUseCase(), onDelegate: { _ in })
        }
        
        await store.send(.binding(.set(\.memo, "Great track"))) {
            $0.memo = "Great track"
        }
    }
    
    func testCloseTapped() async {
        let store = TestStore(initialState: AddArchiveFeature.State()) {
            AddArchiveFeature(archiveRepository: MockArchiveRepository(), searchTracksUseCase: MockSearchTracksUseCase(), onDelegate: { _ in })
        }
        
        await store.send(.closeButtonTapped)
    }
}

final class MockArchiveRepository: ArchiveRepository, @unchecked Sendable {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return [] }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockSearchTracksUseCase: SearchTracksUseCase, @unchecked Sendable {
    func execute(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
        return ([], 0)
    }
}
