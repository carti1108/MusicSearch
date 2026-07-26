import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain
import TrackSearchDomain
import FeatureArchiveInterface
import ArchiveSharedTesting
import FeatureTrackSearchTesting
import MSTesting

final class ExampleAppComponent: Component<EmptyDependency>, ArchiveDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
        super.init(dependency: EmptyComponent())
    }
    
    var archiveRepository: any ArchiveRepository {
        let tracks = scenario == .empty ? [] : [ArchivedTrack(title: "Test", artist: "Artist", genre: "Pop", label: "Label", rating: 5)]
        return MockArchiveRepository(tracks: tracks)
    }
    var searchTracksUseCase: any SearchTracksUseCase { MockSearchTracksUseCase() }
    var exportPlaylistUseCase: any ExportPlaylistUseCase { MockExportPlaylistUseCase() }
    var getMusicAccessTokenUseCase: any GetMusicAccessTokenUseCase { MockGetMusicAccessTokenUseCase() }
    var authorizeMusicUseCase: any AuthorizeMusicUseCase { MockAuthorizeMusicUseCase() }
}

