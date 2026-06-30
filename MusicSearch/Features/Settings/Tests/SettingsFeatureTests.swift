import XCTest
import ComposableArchitecture
import MSDomain
@testable import FeatureSettings

@MainActor
final class SettingsFeatureTests: XCTestCase {
    func testOnAppearWithToken() async {
        let mockFetch = MockFetchSpotifyProfileUseCase(profile: ("Test User", nil))
        let mockManage = MockManageSpotifyAuthUseCase(token: "token")

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(manageSpotifyAuthUseCase: mockManage, fetchSpotifyProfileUseCase: mockFetch)
        }

        await store.send(.onAppear)
        await store.receive(\.fetchProfileResponse.success) {
            $0.spotifyState = .connected(name: "Test User", imageURL: nil)
        }
    }

    func testOnAppearWithoutToken() async {
        let mockFetch = MockFetchSpotifyProfileUseCase(profile: nil)
        let mockManage = MockManageSpotifyAuthUseCase(token: nil)

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(manageSpotifyAuthUseCase: mockManage, fetchSpotifyProfileUseCase: mockFetch)
        }

        await store.send(.onAppear)
        await store.receive(\.fetchProfileResponse.success) {
            $0.spotifyState = .disconnected
        }
    }

    func testLoginTapped() async {
        let mockFetch = MockFetchSpotifyProfileUseCase(profile: ("Test User", nil))
        let mockManage = MockManageSpotifyAuthUseCase(token: nil)

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(manageSpotifyAuthUseCase: mockManage, fetchSpotifyProfileUseCase: mockFetch)
        }

        await store.send(.loginTapped)
        await store.receive(\.authResponse.success)

        mockManage.token = "token"
        await store.receive(\.onAppear)

        await store.receive(\.fetchProfileResponse.success) {
            $0.spotifyState = .connected(name: "Test User", imageURL: nil)
        }
    }

    func testDisconnectTapped() async {
        let mockFetch = MockFetchSpotifyProfileUseCase(profile: nil)
        let mockManage = MockManageSpotifyAuthUseCase(token: "token")

        var state = SettingsFeature.State()
        state.spotifyState = .connected(name: "Test User", imageURL: nil)

        let store = TestStore(initialState: state) {
            SettingsFeature(manageSpotifyAuthUseCase: mockManage, fetchSpotifyProfileUseCase: mockFetch)
        }

        await store.send(.disconnectTapped) {
            $0.spotifyState = .disconnected
        }
        XCTAssertNil(mockManage.getAccessToken())
    }
}

final class MockManageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
    var token: String?
    init(token: String?) { self.token = token }
    func getAccessToken() -> String? { return token }
    func authorize() async throws { token = "token" }
    func disconnect() { token = nil }
}

final class MockFetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase {
    var profile: (String, URL?)?
    init(profile: (String, URL?)?) { self.profile = profile }
    func execute() async throws -> (name: String, imageURL: URL?) {
        if let profile = profile { return profile }
        throw NSError(domain: "Test", code: 0)
    }
}
