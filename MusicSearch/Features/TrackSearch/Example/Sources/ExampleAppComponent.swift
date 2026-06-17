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

@MainActor
final class ExampleAppComponent: TrackSearchDependency {
    var searchTracksUseCase: SearchTracksUseCase {
        MockSearchTracksUseCase()
    }
    var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
        MockFetchTracksByTagUseCase()
    }
    var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
        MockFetchSimilarTracksUseCase()
    }
    var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
        MockFetchMusicAppDeepLinkUseCase()
    }
    var urlOpener: URLOpening {
        MockURLOpener()
    }
    var musicDiggingBuilder: MusicDiggingBuildable {
        MockMusicDiggingBuildable()
    }
}

final class MockSearchTracksUseCase: SearchTracksUseCase {
    func execute(
        query: String,
        limit: Int,
        page: Int
    ) async throws -> (tracks: [Track], totalResults: Int) {
        let tracks = [
            Track(title: "Mock Track 1", artist: "Mock Artist", imageURL: nil),
            Track(title: "Mock Track 2", artist: "Mock Artist", imageURL: nil)
        ]
        return (tracks: tracks, totalResults: 2)
    }
}

final class MockFetchTracksByTagUseCase: FetchTracksByTagUseCase {
    func execute(tag: String) async throws -> [Track] { return [] }
}

final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
    func execute(targetTrack: Track) async throws -> [Track] { return [] }
}

final class MockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    func execute(track: Track) async -> URL? { nil }
    func execute(artist: String) async -> URL? { nil }
}

final class MockURLOpener: URLOpening {
    func open(_ url: URL) {}
}

@MainActor
final class MockMusicDiggingBuildable: MusicDiggingBuildable {
    func build(
        withListener listener: MusicDiggingListener,
        seedTrack: Track
    ) -> MusicDiggingRouting {
        MockMusicDiggingRouting(
            interactor: MockMusicDiggingInteractor(),
            viewControllable: MockViewControllable()
        )
    }
}

@MainActor
final class MockMusicDiggingRouting: ViewableRouting {
    var viewControllable: ViewControllable
    var interactable: Interactable
    var children: [Routing] = []
    
    init(interactor: Interactable, viewControllable: ViewControllable) {
        self.interactable = interactor
        self.viewControllable = viewControllable
    }
    
    func load() {}
    func attachChild(_ child: Routing) {}
    func detachChild(_ child: Routing) {}
    var lifecycle: AnyPublisher<RouterLifecycle, Never> { Empty().eraseToAnyPublisher() }
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
