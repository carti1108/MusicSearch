import Foundation
import UIKit
import MicroRIBs
import MSDomain
import FeatureSettings
import FeatureSettingsInterface

@MainActor
final class ExampleAppComponent: SettingsDependency {
    var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase, authorizeMusicUseCase: AuthorizeMusicUseCase, disconnectMusicUseCase: DisconnectMusicUseCase {
        MockManageMusicAuthUseCase()
    }

    var fetchUserProfileUseCase: FetchUserProfileUseCase {
        MockFetchUserProfileUseCase()
    }
}

// MARK: - Mocks

final class MockManageMusicAuthUseCase: ManageMusicAuthUseCase {
    func getAccessToken() -> String? { return nil }
    func authorize() async throws { }
    func disconnect() { }
}

final class MockFetchUserProfileUseCase: FetchUserProfileUseCase {
    func execute() async throws -> (name: String, imageURL: URL?) {
        return (name: "Test User", imageURL: nil)
    }
}
