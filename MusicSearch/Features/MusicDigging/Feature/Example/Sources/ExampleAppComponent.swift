import Foundation
import UIKit
import MSDomain
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import MSUtil
import MusicDiggingDomain

@MainActor
final class ExampleAppComponent: MusicDiggingDependency {
    var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
        MockFetchSimilarTracksUseCase()
    }
    var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
        MockFetchTrackDeepLinkUseCase()
    }
    var urlOpener: URLOpening {
        MockURLOpener()
    }
}

final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
	func execute(targetTrack track: Track) async throws -> [Track] {
        return [
            Track(title: "Mock Similar 1", artist: "Mock Artist", imageURL: nil),
            Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
			Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil)
        ]
    }
}

final class MockFetchTrackDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    func execute(track: Track) async -> URL? { nil }
    
}

final class MockURLOpener: URLOpening {
    func open(_ url: URL) {}
}
