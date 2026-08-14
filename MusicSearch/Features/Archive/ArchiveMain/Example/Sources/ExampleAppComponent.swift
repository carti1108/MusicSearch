import Foundation
import ArchiveDomain
import ArchiveSharedTesting
import FeatureArchiveInterface
import FeatureTrackSearchTesting
import MicroRIBs
import MSDomain
import MSTesting
import TrackSearchDomain

final class ExampleAppComponent: Component<EmptyDependency>, ArchiveDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
        super.init(dependency: EmptyComponent())
    }
    
    var archiveRepository: any ArchiveRepository {
        let tracks = scenario == .empty ? [] : [ArchivedTrack(title: "Test", artist: "Artist", genres: ["Pop"], label: "Label", rating: 5)]
        return MockArchiveRepository(tracks: tracks)
    }
    var searchTracksUseCase: any SearchTracksUseCase { MockSearchTracksUseCase() }
    var exportPlaylistUseCase: any ExportPlaylistUseCase { MockExportPlaylistUseCase() }
    var getMusicAccessTokenUseCase: any GetMusicAccessTokenUseCase { MockGetMusicAccessTokenUseCase() }
    var authorizeMusicUseCase: any AuthorizeMusicUseCase { MockAuthorizeMusicUseCase() }
}


