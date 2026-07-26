//
//  SettingsFeatureTests.swift
//  MusicSearch
//
//  Created by Kiseok on 6/23/26.
//

import Foundation
import Testing
import ComposableArchitecture
import MSDomain
import MSTesting
@testable import FeatureSettings

@MainActor
struct SettingsFeatureTests {
    @Test func testOnAppearWithToken() async {
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

    @Test func testOnAppearWithoutToken() async {
        let mockFetch = MockFetchUserProfileUseCase(profile: nil)
        let mockGet = MockGetMusicAccessTokenUseCase(token: nil)
        let mockAuth = MockAuthorizeMusicUseCase()
        let mockDisconnect = MockDisconnectMusicUseCase()

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(getMusicAccessTokenUseCase: mockGet, authorizeMusicUseCase: mockAuth, disconnectMusicUseCase: mockDisconnect, fetchUserProfileUseCase: mockFetch)
        }

        await store.send(.onAppear)
        await store.receive(\.fetchProfileResponse.success)
    }

    @Test func testLoginTapped() async {
        let mockFetch = MockFetchUserProfileUseCase(profile: ("Test User", nil))
        let mockGet = MockGetMusicAccessTokenUseCase(token: nil)
        let mockAuth = MockAuthorizeMusicUseCase()
        let mockDisconnect = MockDisconnectMusicUseCase()

        let store = TestStore(initialState: SettingsFeature.State()) {
            SettingsFeature(getMusicAccessTokenUseCase: mockGet, authorizeMusicUseCase: mockAuth, disconnectMusicUseCase: mockDisconnect, fetchUserProfileUseCase: mockFetch)
        }
        store.exhaustivity = .off

        mockGet.token = "token"
        await store.send(.loginTapped)

        await store.receive(\.fetchProfileResponse.success) {
            $0.spotifyState = .connected(name: "Test User", imageURL: nil)
        }
    }

    @Test func testDisconnectTapped() async {
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
        #expect(mockDisconnect.disconnectCalled)
    }
}
