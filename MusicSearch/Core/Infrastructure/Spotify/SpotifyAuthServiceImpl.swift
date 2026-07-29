//
//  SpotifyAuthServiceImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation
import MSDomain
import NetworkLayer
import MSUtil

public final class SpotifyAuthServiceImpl: MusicAuthService {
	
    private let networkManager: NetworkRequesting
    private let keychainService: KeychainService

    public init(networkManager: NetworkRequesting, keychainService: KeychainService = KeychainServiceImpl.shared) {
        self.networkManager = networkManager
        self.keychainService = keychainService
    }

    public func getAccessToken() -> String? {
        return self.keychainService.read(forKey: "SpotifyAccessToken")
    }

    public func authorize() async throws {
        let config = DefaultSpotifyAPIConfiguration()
        let code = try await SpotifyAuthManager.shared.authorize(config: config)

        let response = try await SpotifyAuthManager.shared.exchangeToken(code: code, config: config, networkManager: self.networkManager)

        _ = self.keychainService.save(response.access_token, forKey: "SpotifyAccessToken")
        if let refreshToken = response.refresh_token {
            _ = self.keychainService.save(refreshToken, forKey: "SpotifyRefreshToken")
        }

        UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(response.expires_in)), forKey: "SpotifyTokenExpiry")
    }

    public func disconnect() {
        _ = self.keychainService.delete(forKey: "SpotifyAccessToken")
        _ = self.keychainService.delete(forKey: "SpotifyRefreshToken")
        UserDefaults.standard.removeObject(forKey: "SpotifyTokenExpiry")
    }

    public func getClientCredentialsToken() async throws -> String {
        let now = Date()
        if let token = UserDefaults.standard.string(forKey: "SpotifyClientToken"),
           let expiry = UserDefaults.standard.object(forKey: "SpotifyClientTokenExpiry") as? Date,
           now < expiry {
            return token
        }

        let config = DefaultSpotifyAPIConfiguration()
        let api = SpotifyAPI.clientCredentialsToken(config: config)
        let response = try await self.networkManager.perform(with: api, as: SpotifyTokenResponse.self)

        UserDefaults.standard.set(response.access_token, forKey: "SpotifyClientToken")
        UserDefaults.standard.set(now.addingTimeInterval(TimeInterval(response.expires_in - 60)), forKey: "SpotifyClientTokenExpiry")

        return response.access_token
    }

    public func fetchUserProfile() async throws -> (name: String, imageURL: URL?) {
        guard let token = self.getAccessToken() else {
            throw URLError(.userAuthenticationRequired)
        }

        let api = SpotifyAPI.me(token: token, config: DefaultSpotifyAPIConfiguration())
        let response = try await self.networkManager.perform(with: api, as: SpotifyUserProfileResponse.self)

        let name = response.display_name ?? "Spotify User"
        let urlString = response.images?.first?.url
        let imageURL = urlString != nil ? URL(string: urlString!) : nil

        return (name: name, imageURL: imageURL)
    }
}
