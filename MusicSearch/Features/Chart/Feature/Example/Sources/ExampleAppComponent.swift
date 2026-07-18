import Foundation
import MSDomain
import FeatureChart
import FeatureChartInterface
import MSUtil
import ChartDomain
import FeatureChartTesting

@MainActor
final class ExampleAppComponent: ChartDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
    }
    
    var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
        let mock = MockFetchChartTopTracksUseCase()
        
        switch scenario {
        case .success:
            mock.result = [
                Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
                Track(title: "How Sweet", artist: "NewJeans", imageURL: nil),
                Track(title: "Bubble Gum", artist: "NewJeans", imageURL: nil),
                Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
                Track(title: "How Sweet", artist: "NewJeans", imageURL: nil),
                Track(title: "Bubble Gum", artist: "NewJeans", imageURL: nil)
            ]
        case .empty:
            mock.result = []
        case .error:
            mock.errorToThrow = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "네트워크 에러 발생"])
        case .delayed:
            mock.delay = 2.0
            mock.result = [
                Track(title: "Supernova", artist: "aespa", imageURL: URL(string: "https://example.com/1")),
                Track(title: "How Sweet", artist: "NewJeans", imageURL: nil)
            ]
        }
        
        return mock
    }

    var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
        let mock = MockFetchChartTopArtistsUseCase()
        
        switch scenario {
        case .success:
            mock.result = [
                Artist(name: "aespa", imageURL: nil),
                Artist(name: "NewJeans", imageURL: nil),
                Artist(name: "IVE", imageURL: nil),
                Artist(name: "aespa", imageURL: nil),
                Artist(name: "NewJeans", imageURL: nil),
                Artist(name: "IVE", imageURL: nil)
            ]
        case .empty:
            mock.result = []
        case .error:
            mock.errorToThrow = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "네트워크 에러 발생"])
        case .delayed:
            mock.delay = 2.0
            mock.result = [
                Artist(name: "aespa", imageURL: nil),
                Artist(name: "NewJeans", imageURL: nil)
            ]
        }
        
        return mock
    }

    var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
        MockFetchTrackDeepLinkUseCaseForChartBuilder()
    }

    var fetchArtistDeepLinkUseCase: FetchArtistDeepLinkUseCase {
        MockFetchArtistDeepLinkUseCaseForChartBuilder()
    }

    var urlOpener: URLOpening {
        MockURLOpener()
    }
}

