import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain
import TrackSearchDomain
import FeatureArchiveInterface

final class ExampleAppComponent: Component<EmptyDependency>, ArchiveDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
        super.init(dependency: EmptyComponent())
    }
    
    var archiveRepository: any ArchiveRepository { MockArchiveRepository(scenario: scenario) }
    var searchTracksUseCase: any SearchTracksUseCase { MockSearchTracksUseCase() }
    var exportPlaylistUseCase: any ExportPlaylistUseCase { MockExportPlaylistUseCase() }
    var getMusicAccessTokenUseCase: any GetMusicAccessTokenUseCase { MockGetMusicAccessTokenUseCase() }
    var authorizeMusicUseCase: any AuthorizeMusicUseCase { MockAuthorizeMusicUseCase() }
}

final class MockArchiveRepository: ArchiveRepository, @unchecked Sendable {
    let scenario: DemoScenario
    init(scenario: DemoScenario) { self.scenario = scenario }
    func fetchArchivedTracks() async throws -> [ArchivedTrack] {
        if scenario == .empty { return [] }
        if scenario == .error { throw NSError(domain: "test", code: 1) }
        if scenario == .delayed { try await Task.sleep(nanoseconds: 2_000_000_000) }
        return [ArchivedTrack(title: "Test", artist: "Artist", genre: "Pop", label: "Label", rating: 5)]
    }
    func addArchivedTrack(_ track: ArchivedTrack) async throws {}
    func updateArchivedTrack(_ track: ArchivedTrack) async throws {}
    func deleteArchivedTrack(id: UUID) async throws {}
}

final class MockSearchTracksUseCase: SearchTracksUseCase, @unchecked Sendable {
    func execute(query: String, limit: Int, offset: Int) async throws -> (tracks: [Track], totalResults: Int) {
        return ([], 0)
    }
}

final class MockExportPlaylistUseCase: ExportPlaylistUseCase, @unchecked Sendable {
    func execute(tracks: [ArchivedTrack], playlistName: String) -> AsyncStream<ExportProgress> {
        let (stream, continuation) = AsyncStream.makeStream(of: ExportProgress.self)
        continuation.yield(ExportProgress(totalCount: 1, currentCount: 1, failedTracks: [], isComplete: true))
        continuation.finish()
        return stream
    }
}

final class MockGetMusicAccessTokenUseCase: GetMusicAccessTokenUseCase, @unchecked Sendable {
    func execute() -> String? { return "token" }
}

final class MockAuthorizeMusicUseCase: AuthorizeMusicUseCase, @unchecked Sendable {
    func execute() async throws {}
}
