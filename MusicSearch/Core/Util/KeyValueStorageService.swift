//
//  KeyValueStorageService.swift
//  MusicSearch
//
//  Created by Kiseok on 7/30/26.
//

import Foundation

public protocol KeyValueStorageService: Sendable {
    func string(forKey key: String) -> String?
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
    func removeObject(forKey key: String)
}

public final class UserDefaultsStorageService: KeyValueStorageService, @unchecked Sendable {
    public static let shared = UserDefaultsStorageService()

	private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func string(forKey key: String) -> String? {
        return self.userDefaults.string(forKey: key)
    }

    public func object(forKey key: String) -> Any? {
        return self.userDefaults.object(forKey: key)
    }

    public func set(_ value: Any?, forKey key: String) {
        self.userDefaults.set(value, forKey: key)
    }

    public func removeObject(forKey key: String) {
        self.userDefaults.removeObject(forKey: key)
    }
}
