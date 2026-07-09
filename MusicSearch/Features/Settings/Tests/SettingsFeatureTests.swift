import XCTest
import ComposableArchitecture
import MSDomain
@testable import FeatureSettings

@MainActor
final class SettingsFeatureTests: XCTestCase {
    func testOnAppearWithToken() async {
        let mockFetch = MockFetchUserProfileUseCase(profile: ("Test User", nil))
        let mockGet = MockGetMusicAccessTokenUseCase(token: "token")
        let mockAuth = MockAuthorizeMusicUseCase()
        let mockDisconnect = MockDisconnectMusicUseCase()

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(getMusicAccessTokenUseCase: mockGet, authorizeMusicUseCase: mockAuth, disconnectMusicUseCase: mockDisconnect, fetchUserProfileUseCase: mockFetch)
        }

        await store.send(.onAppear)
        await store.receive(\.fetchProfileResponse.success) {
            $0.spotifyState = .connected(name: "Test User", imageURL: nil)
        }
    }

    func testOnAppearWithoutToken() async {
        let mockFetch = MockFetchUserProfileUseCase(profile: nil)
        let mockGet = MockGetMusicAccessTokenUseCase(token: nil)
        let mockAuth = MockAuthorizeMusicUseCase()
        let mockDisconnect = MockDisconnectMusicUseCase()

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(getMusicAccessTokenUseCase: mockGet, authorizeMusicUseCase: mockAuth, disconnectMusicUseCase: mockDisconnect, fetchUserProfileUseCase: mockFetch)
        }

        await store.send(.onAppear)
        await store.receive(\.fetchProfileResponse.success) {
            $0.spotifyState = .disconnected
        }
    }

    func testLoginTapped() async {
        let mockFetch = MockFetchUserProfileUseCase(profile: ("Test User", nil))
        let mockGet = MockGetMusicAccessTokenUseCase(token: nil)
        let mockAuth = MockAuthorizeMusicUseCase()
        let mockDisconnect = MockDisconnectMusicUseCase()

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(getMusicAccessTokenUseCase: mockGet, authorizeMusicUseCase: mockAuth, disconnectMusicUseCase: mockDisconnect, fetchUserProfileUseCase: mockFetch)
        }

        await store.send(.loginTapped)
        await store.receive(\.authResponse.success)

        mockGet.token = "token"
        await store.receive(\.onAppear)

        await store.receive(\.fetchProfileResponse.success) {
            $0.spotifyState = .connected(name: "Test User", imageURL: nil)
        }
    }

    func testDisconnectTapped() async {
        let mockFetch = MockFetchUserProfileUseCase(profile: nil)
        let mockGet = MockGetMusicAccessTokenUseCase(token: "token")
        let mockAuth = MockAuthorizeMusicUseCase()
        let mockDisconnect = MockDisconnectMusicUseCase()

        var state = SettingsFeature.State()
        state.spotifyState = .connected(name: "Test User", imageURL: nil)

        let store = TestStore(initialState: state) {
            SettingsFeature(getMusicAccessTokenUseCase: mockGet, authorizeMusicUseCase: mockAuth, disconnectMusicUseCase: mockDisconnect, fetchUserProfileUseCase: mockFetch)
        }

        await store.send(.disconnectTapped) {
            $0.spotifyState = .disconnected
        }
        XCTAssertTrue(mockDisconnect.disconnectCalled)
    }
}


final class MockGetMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
    var token: String?
    init(token: String?) { self.token = token }
    func execute() -> String? { return token }
}

final class MockAuthorizeMusicUseCase: AuthorizeMusicUseCase {
    func execute() async throws { }
}

final class MockDisconnectMusicUseCase: DisconnectMusicUseCase {
    var disconnectCalled = false
    func execute() { disconnectCalled = true }
}


final class MockFetchUserProfileUseCase: FetchUserProfileUseCase {
    var profile: (String, URL?)?
    init(profile: (String, URL?)?) { self.profile = profile }
    func execute() async throws -> (name: String, imageURL: URL?) {
        if let profile = profile { return profile }
        throw NSError(domain: "Test", code: 0)
    }
}
