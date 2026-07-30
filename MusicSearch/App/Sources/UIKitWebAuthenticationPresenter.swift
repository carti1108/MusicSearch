//
//  UIKitWebAuthenticationPresenter.swift
//  MusicSearch
//
//  Created by Kiseok on 7/30/26.
//

import UIKit
import AuthenticationServices
import MSDomain

@MainActor
public final class UIKitWebAuthenticationPresenter: NSObject, WebAuthenticationPresenter, ASWebAuthenticationPresentationContextProviding {
    private var authSession: ASWebAuthenticationSession?

    public override init() {
        super.init()
    }

    public func present(url: URL, callbackURLScheme: String) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { [weak self] callbackURL, error in
                self?.authSession = nil
                if let error = error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: URLError(.cancelled))
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }

                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }

                continuation.resume(returning: callbackURL)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.authSession = session
            session.start()
        }
    }

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        return windowScene?.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}
