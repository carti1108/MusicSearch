//
//  MockKeychainService.swift
//  MusicSearch
//
//  Created by Kiseok on 7/29/26.
//

import Foundation
import MSDomain
import MSUtil

public final class MockKeychainService: KeychainService, @unchecked Sendable {
    private var storage: [String: String]

    public init(storage: [String: String] = [:]) {
        self.storage = storage
    }

    public func read(forKey key: String) -> String? {
        return self.storage[key]
    }

    public func save(_ value: String, forKey key: String) -> Bool {
        self.storage[key] = value
        return true
    }

    public func delete(forKey key: String) -> Bool {
        self.storage.removeValue(forKey: key)
        return true
    }
}
