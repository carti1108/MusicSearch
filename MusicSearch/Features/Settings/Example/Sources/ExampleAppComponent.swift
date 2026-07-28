//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/23/26.
//

import Foundation
import UIKit
import MSDomain
import FeatureSettings
import FeatureSettingsInterface
import MSUtil
import MSTesting

@MainActor
final class ExampleAppComponent: SettingsDependency {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario) {
        self.scenario = scenario
    }
    
    var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
        let mock = MockGetMusicAccessTokenUseCase()
        return mock
    }
    
    var authorizeMusicUseCase: AuthorizeMusicUseCase {
        let mock = MockAuthorizeMusicUseCase()
        return mock
    }
    
    var disconnectMusicUseCase: DisconnectMusicUseCase {
        let mock = MockDisconnectMusicUseCase()
        return mock
    }
    
    var fetchUserProfileUseCase: FetchUserProfileUseCase {
        let mock = MockFetchUserProfileUseCase(scenario: scenario)
        return mock
    }
    var urlOpener: URLOpening {
        MockURLOpener()
    }
}

