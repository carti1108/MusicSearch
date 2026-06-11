import Foundation
import UIKit
import MSDomain
import FeatureTrackSearch
import FeatureTrackSearchInterface
import MSUtil

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
}

final class MockSearchTracksUseCase: SearchTracksUseCase {
    func execute(query: String) async throws -> [Track] {
        return [
            Track(title: "Mock Track 1", artist: "Mock Artist", imageURL: nil),
            Track(title: "Mock Track 2", artist: "Mock Artist", imageURL: nil)
        ]
    }
}

final class MockFetchTracksByTagUseCase: FetchTracksByTagUseCase {
    func execute(tag: String) async throws -> [Track] { return [] }
}

final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
    func execute(track: Track) async throws -> [Track] { return [] }
}

final class MockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    func execute(track: Track) async -> URL? { nil }
    func execute(artist: String) async -> URL? { nil }
}

final class MockURLOpener: URLOpening {
    func open(_ url: URL) {}
}
