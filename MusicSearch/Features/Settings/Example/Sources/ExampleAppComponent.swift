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
final class MockGetMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
    func execute() -> String? { return "mock_token" }
}

final class MockAuthorizeMusicUseCase: AuthorizeMusicUseCase {
    func execute() async throws {}
}

final class MockDisconnectMusicUseCase: DisconnectMusicUseCase {
    func execute() {}
}

final class MockFetchUserProfileUseCase: FetchUserProfileUseCase {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario = .success) {
        self.scenario = scenario
    }
    
    func execute() async throws -> (name: String, imageURL: URL?) {
        switch scenario {
        case .success:
            return (name: "Demo User", imageURL: nil)
        case .empty:
            return (name: "", imageURL: nil)
        case .error:
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "프로필 로드 에러"])
        case .delayed:
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            return (name: "Delayed User", imageURL: nil)
        }
    }
}

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
