//
//  WebAuthenticationPresenter.swift
//  MusicSearch
//
//  Created by Kiseok on 7/30/26.
//

import Foundation

public protocol WebAuthenticationPresenter: Sendable {
    @MainActor
    func present(url: URL, callbackURLScheme: String) async throws -> URL
}
