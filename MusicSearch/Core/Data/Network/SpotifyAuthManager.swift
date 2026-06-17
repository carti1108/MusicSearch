import Foundation
import UIKit
import AuthenticationServices
import NetworkLayer

@MainActor
public final class SpotifyAuthManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    public static let shared = SpotifyAuthManager()
    
    private var pendingContinuation: CheckedContinuation<String, Error>?
    
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
        let authURLString = "\(config.accountsBaseURL)/authorize?client_id=\(config.clientId)&response_type=code&redirect_uri=\(config.redirectURI)&scope=playlist-modify-public%20playlist-modify-private%20user-read-private"
        guard let authURL = URL(string: authURLString) else { throw URLError(.badURL) }
        
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "musicsearch") { callbackURL, error in
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
        let api = SpotifyAPI.exchangeToken(code: code, config: config)
        return try await networkManager.perform(with: api, as: SpotifyTokenResponse.self)
    }
}