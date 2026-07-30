//
//  MockWebAuthenticationPresenter.swift
//  MusicSearch
//
//  Created by Kiseok on 7/30/26.
//

import Foundation
import MSDomain

public final class MockWebAuthenticationPresenter: WebAuthenticationPresenter, @unchecked Sendable {
    public var resultToReturn: Result<URL, Error>

    public init(resultToReturn: Result<URL, Error> = .success(URL(string: "musicsearch://callback?code=mock_authorization_code")!)) {
        self.resultToReturn = resultToReturn
    }

    @MainActor
    public func present(url: URL, callbackURLScheme: String) async throws -> URL {
        return try self.resultToReturn.get()
    }
}
