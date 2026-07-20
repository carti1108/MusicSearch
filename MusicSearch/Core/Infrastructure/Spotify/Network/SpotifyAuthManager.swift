//
//  SpotifyAuthManager.swift
//  MusicSearch
//
//  Created by Kiseok on 7/9/26.
//

import Foundation
import UIKit
import AuthenticationServices
import NetworkLayer
import CryptoKit

@MainActor
public final class SpotifyAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    public static let shared = SpotifyAuthManager()

    private var pendingContinuation: CheckedContinuation<String, Error>?
    private var pendingCodeVerifier: String?
    private var authSession: ASWebAuthenticationSession?

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

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("SpotifyAuthCallback"), object: nil)
    }

    @objc private func handleNotification(_ notification: Notification) {
        if let url = notification.object as? URL {
            self.handle(url: url)
        }
    }

    public func authorize(config: SpotifyAPIConfiguration) async throws -> String {
        let verifier = generateCodeVerifier()
        self.pendingCodeVerifier = verifier
        let challenge = generateCodeChallenge(verifier: verifier)

        let authURLString = "\(config.accountsBaseURL)/authorize?client_id=\(config.clientId)&response_type=code&redirect_uri=\(config.redirectURI)&scope=playlist-modify-public%20playlist-modify-private%20user-read-private&code_challenge_method=S256&code_challenge=\(challenge)"
        guard let authURL = URL(string: authURLString) else { throw URLError(.badURL) }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "musicsearch") { [weak self] callbackURL, error in
                self?.authSession = nil
                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: URLError(.cancelled))
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                guard let callbackURL = callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                continuation.resume(returning: code)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.authSession = session
            session.start()
        }
    }

    public func handle(url: URL) {
        guard url.scheme == "musicsearch" else { return }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        if let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
            pendingContinuation?.resume(returning: code)
            pendingContinuation = nil
        } else if let _ = components.queryItems?.first(where: { $0.name == "error" })?.value {
            pendingContinuation?.resume(throwing: URLError(.userAuthenticationRequired))
            pendingContinuation = nil
        }
    }

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }

    public func exchangeToken(code: String, config: SpotifyAPIConfiguration, networkManager: NetworkRequesting) async throws -> SpotifyTokenResponse {
        guard let verifier = pendingCodeVerifier else {
            throw URLError(.userAuthenticationRequired)
        }
        let api = SpotifyAPI.exchangeToken(code: code, codeVerifier: verifier, config: config)
        let response = try await networkManager.perform(with: api, as: SpotifyTokenResponse.self)
        self.pendingCodeVerifier = nil
        return response
    }
}
