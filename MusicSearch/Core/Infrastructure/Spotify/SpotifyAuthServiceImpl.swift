//
//  SpotifyAuthServiceImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation
import CryptoKit
import MSDomain
import NetworkLayer
import MSUtil

public final class SpotifyAuthServiceImpl: MusicAuthService {
    private let networkManager: NetworkRequesting
    private let keychainService: KeychainService
    private let webAuthPresenter: WebAuthenticationPresenter?
    private let keyValueStorage: KeyValueStorageService

    public init(
        networkManager: NetworkRequesting,
        keychainService: KeychainService = KeychainServiceImpl.shared,
        webAuthPresenter: WebAuthenticationPresenter? = nil,
        keyValueStorage: KeyValueStorageService = UserDefaultsStorageService.shared
    ) {
        self.networkManager = networkManager
        self.keychainService = keychainService
        self.webAuthPresenter = webAuthPresenter
        self.keyValueStorage = keyValueStorage
    }

    private func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 64)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        let data = Data(buffer)
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func generateCodeChallenge(verifier: String) -> String {
        guard let data = verifier.data(using: .ascii) else { return "" }
        let hash = SHA256.hash(data: data)
        let hashData = Data(hash)
        return hashData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    public func getAccessToken() -> String? {
        return self.keychainService.read(forKey: "SpotifyAccessToken")
    }

    public func authorize() async throws {
        guard let presenter = self.webAuthPresenter else {
            throw URLError(.cannotConnectToHost)
        }

        let verifier = self.generateCodeVerifier()
        let challenge = self.generateCodeChallenge(verifier: verifier)

        let config = DefaultSpotifyAPIConfiguration()
        let authURLString = "\(config.accountsBaseURL)/authorize?client_id=\(config.clientId)&response_type=code&redirect_uri=\(config.redirectURI)&scope=playlist-modify-public%20playlist-modify-private%20user-read-private&code_challenge_method=S256&code_challenge=\(challenge)"
        guard let authURL = URL(string: authURLString) else { throw URLError(.badURL) }

        let callbackURL = try await presenter.present(url: authURL, callbackURLScheme: "musicsearch")
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw URLError(.badServerResponse)
        }

        let api = SpotifyAPI.exchangeToken(code: code, codeVerifier: verifier, config: config)
        let response = try await self.networkManager.perform(with: api, as: SpotifyTokenResponse.self)

        _ = self.keychainService.save(response.access_token, forKey: "SpotifyAccessToken")
        if let refreshToken = response.refresh_token {
            _ = self.keychainService.save(refreshToken, forKey: "SpotifyRefreshToken")
        }

        self.keyValueStorage.set(Date().addingTimeInterval(TimeInterval(response.expires_in)), forKey: "SpotifyTokenExpiry")
    }

    public func disconnect() {
        _ = self.keychainService.delete(forKey: "SpotifyAccessToken")
        _ = self.keychainService.delete(forKey: "SpotifyRefreshToken")
        self.keyValueStorage.removeObject(forKey: "SpotifyTokenExpiry")
    }

    public func getClientCredentialsToken() async throws -> String {
        let now = Date()
        if let token = self.keyValueStorage.string(forKey: "SpotifyClientToken"),
           let expiry = self.keyValueStorage.object(forKey: "SpotifyClientTokenExpiry") as? Date,
           now < expiry {
            return token
        }

        let config = DefaultSpotifyAPIConfiguration()
        let api = SpotifyAPI.clientCredentialsToken(config: config)
        let response = try await self.networkManager.perform(with: api, as: SpotifyTokenResponse.self)

        self.keyValueStorage.set(response.access_token, forKey: "SpotifyClientToken")
        self.keyValueStorage.set(now.addingTimeInterval(TimeInterval(response.expires_in - 60)), forKey: "SpotifyClientTokenExpiry")

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
