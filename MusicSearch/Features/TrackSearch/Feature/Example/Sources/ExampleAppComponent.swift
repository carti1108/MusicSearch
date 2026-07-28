//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Combine
import Foundation
import UIKit
import FeatureMusicDiggingInterface
import FeatureMusicDiggingTesting
import FeatureTrackSearch
import FeatureTrackSearchInterface
import FeatureTrackSearchTesting
import MicroRIBs
import MSDomain
import MSTesting
import MSUtil
import MusicDiggingDomain
import TrackSearchDomain

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
        MusicDiggingBuilderSpy()
    }
}


