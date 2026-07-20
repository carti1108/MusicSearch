//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import UIKit
import MSDomain
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import MSUtil
import MusicDiggingDomain
import FeatureMusicDiggingTesting

@MainActor
final class ExampleAppComponent: MusicDiggingDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
    }
    
    var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
        let mock = MockFetchSimilarTracksUseCase()
        
        switch scenario {
        case .success:
            mock.result = [
                Track(title: "Mock Similar 1", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Similar 3", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Similar 4", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Similar 5", artist: "Mock Artist", imageURL: nil)
            ]
        case .empty:
            mock.result = []
        case .error:
            mock.errorToThrow = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "네트워크 에러 발생"])
        case .delayed:
            mock.delay = 2.0
            mock.result = [
                Track(title: "Mock Similar 1", artist: "Mock Artist", imageURL: nil),
                Track(title: "Mock Similar 2", artist: "Mock Artist", imageURL: nil)
            ]
        }
        
        return mock
    }
    
    var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
        MockFetchTrackDeepLinkUseCaseForMusicDiggingBuilder()
    }
    var urlOpener: URLOpening {
        MockURLOpener()
    }
}
