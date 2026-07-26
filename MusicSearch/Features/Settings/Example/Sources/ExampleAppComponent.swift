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
}

// MARK: - Mocks

final class AlertingURLOpener: URLOpening {
    @MainActor
    func open(_ url: URL) {
        let alert = UIAlertController(title: "URL Opened", message: url.absoluteString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(alert, animated: true)
        }
    }
}
