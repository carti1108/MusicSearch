import Foundation
import UIKit
import Combine
import MSDomain
import FeatureTrackSearch
import FeatureTrackSearchInterface
import MSUtil
import TrackSearchDomain
import MusicDiggingDomain
import FeatureMusicDiggingInterface
import MicroRIBs
import FeatureTrackSearchTesting

@MainActor
final class ExampleAppComponent: TrackSearchDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
    }
    
    var searchTracksUseCase: SearchTracksUseCase {
        let mock = MockSearchTracksUseCase()
        
        switch scenario {
        case .success:
            mock.result = (tracks: [
                Track(title: "Mock Track 1", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Track 2", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Track 3", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Track 4", artist: "Mock Artist", imageURL: nil)
            ], totalResults: 4)
        case .empty:
            mock.result = (tracks: [], totalResults: 0)
        case .error:
            mock.errorToThrow = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "네트워크 에러 발생"])
        case .delayed:
            mock.delay = 2.0
            mock.result = (tracks: [
                Track(title: "Mock Track 1", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Track 2", artist: "Mock Artist", imageURL: nil)
            ], totalResults: 2)
        }
        
        return mock
    }
    var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
        MockFetchTracksByTagUseCase()
    }
    var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
        MockFetchSimilarTracksUseCase()
    }
    var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
        MockFetchTrackDeepLinkUseCase()
    }
    var urlOpener: URLOpening {
        MockURLOpener()
    }
    var musicDiggingBuilder: MusicDiggingBuildable {
        MockMusicDiggingBuildableForExample()
    }
}

@MainActor
final class MockMusicDiggingBuildableForExample: MusicDiggingBuildable {
    func build(withListener listener: MusicDiggingListener, seedTrack: Track) -> MusicDiggingRouting {
        return MockMusicDiggingRouting(
            interactor: MockMusicDiggingInteractor(),
            viewController: MockViewControllable()
        )
    }
}
@MainActor
final class MockMusicDiggingRouting: ViewableRouter<Interactable, ViewControllable>, MusicDiggingRouting {
    override init(interactor: Interactable, viewController: ViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
    }
}

@MainActor
final class MockMusicDiggingInteractor: Interactable {
    var isActive: Bool = true
    var isActiveStream: AsyncStream<Bool> { AsyncStream { $0.yield(true); $0.finish() } }
    func activate() {}
    func deactivate() {}
}

@MainActor
final class MockViewControllable: ViewControllable {
    var uiViewController: UIViewController { UIViewController() }
}
