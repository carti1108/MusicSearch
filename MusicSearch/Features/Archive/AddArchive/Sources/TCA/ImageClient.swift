//
//  ImageClient.swift
//  MusicSearch
//
//  Created by Kiseok on 7/25/26.
//

import Foundation
import ComposableArchitecture

public struct ImageClient: Sendable {
    public var fetch: @Sendable (URL) async throws -> Data
}

extension ImageClient: DependencyKey {
    public static let liveValue = ImageClient(
        fetch: { url in
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return data
        }
    )
}

public extension DependencyValues {
    var imageClient: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}
