//
//  MockKeyValueStorageService.swift
//  MusicSearch
//
//  Created by Kiseok on 7/30/26.
//

import Foundation
import MSUtil

public final class MockKeyValueStorageService: KeyValueStorageService, @unchecked Sendable {
    private var storage: [String: Any]

    public init(storage: [String: Any] = [:]) {
        self.storage = storage
    }

    public func string(forKey key: String) -> String? {
        return self.storage[key] as? String
    }

    public func object(forKey key: String) -> Any? {
        return self.storage[key]
    }

    public func set(_ value: Any?, forKey key: String) {
        if let value = value {
            self.storage[key] = value
        } else {
            self.storage.removeValue(forKey: key)
        }
    }

    public func removeObject(forKey key: String) {
        self.storage.removeValue(forKey: key)
    }
}
