import Foundation
import UIKit
import MicroRIBs
import MSDomain
import FeatureSettings
import FeatureSettingsInterface

@MainActor
final class ExampleAppComponent: SettingsDependency {
    var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
        MockManageSpotifyAuthUseCase()
    }

    var fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase {
        MockFetchSpotifyProfileUseCase()
    }
}

// MARK: - Mocks

final class MockManageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
    func getAccessToken() -> String? { return nil }
    func authorize() async throws { }
    func disconnect() { }
}

final class MockFetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase {
    func execute() async throws -> (name: String, imageURL: URL?) {
        return (name: "Test User", imageURL: nil)
    }
}
