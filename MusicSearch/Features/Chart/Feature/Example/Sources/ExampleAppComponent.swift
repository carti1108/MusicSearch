import Foundation
import MSDomain
import FeatureChart
import FeatureChartInterface
import MSUtil
import ChartDomain

@MainActor
final class ExampleAppComponent: ChartDependency {
    var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
        MockFetchChartTopTracksUseCase()
    }
    
    var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
        MockFetchChartTopArtistsUseCase()
    }
    
    var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
        MockFetchMusicAppDeepLinkUseCase()
    }
    
    var urlOpener: URLOpening {
        MockURLOpener()
    }
}

final class MockFetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
    func execute() async throws -> [Track] {
        return [
            Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
            Track(title: "How Sweet", artist: "NewJeans", imageURL: nil),
            Track(title: "Bubble Gum", artist: "NewJeans", imageURL: nil),
			Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
			Track(title: "How Sweet", artist: "NewJeans", imageURL: nil),
			Track(title: "Bubble Gum", artist: "NewJeans", imageURL: nil),
			Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
			Track(title: "How Sweet", artist: "NewJeans", imageURL: nil),
			Track(title: "Bubble Gum", artist: "NewJeans", imageURL: nil),
			Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
			Track(title: "How Sweet", artist: "NewJeans", imageURL: nil),
			Track(title: "Bubble Gum", artist: "NewJeans", imageURL: nil),
			Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
			Track(title: "How Sweet", artist: "NewJeans", imageURL: nil),
			Track(title: "Bubble Gum", artist: "NewJeans", imageURL: nil)
        ]
    }
}

final class MockFetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
    func execute() async throws -> [Artist] {
        return [
            Artist(name: "aespa", imageURL: nil),
            Artist(name: "NewJeans", imageURL: nil),
            Artist(name: "IVE", imageURL: nil),
			Artist(name: "aespa", imageURL: nil),
			Artist(name: "NewJeans", imageURL: nil),
			Artist(name: "IVE", imageURL: nil),
			Artist(name: "aespa", imageURL: nil),
			Artist(name: "NewJeans", imageURL: nil),
			Artist(name: "IVE", imageURL: nil),
			Artist(name: "aespa", imageURL: nil),
			Artist(name: "NewJeans", imageURL: nil),
			Artist(name: "IVE", imageURL: nil),
			Artist(name: "aespa", imageURL: nil),
			Artist(name: "NewJeans", imageURL: nil),
			Artist(name: "IVE", imageURL: nil)
        ]
    }
}

final class MockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    func execute(track: Track) async -> URL? { nil }
    func execute(artist: String) async -> URL? { nil }
}

final class MockURLOpener: URLOpening {
    func open(_ url: URL) {
        print("Opened URL: \(url)")
    }
}
