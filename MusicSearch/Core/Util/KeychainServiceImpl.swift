//
//  KeychainServiceImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 7/29/26.
//

import Foundation
import Security
import Synchronization

public final class KeychainServiceImpl: KeychainService, Sendable {
    public static let shared = KeychainServiceImpl()

    private struct State {
        var memoryCache: [String: String] = [:]
    }

    private let state = Mutex(State())

    public init() {}

    public func save(_ value: String, forKey key: String) -> Bool {
        self.state.withLock { state in
            state.memoryCache[key] = value
        }

        guard let data = value.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public func read(forKey key: String) -> String? {
        if let cached = self.state.withLock({ $0.memoryCache[key] }) {
            return cached
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let string = String(data: data, encoding: .utf8) else { return nil }

        self.state.withLock { state in
            state.memoryCache[key] = string
        }

        return string
    }

    public func delete(forKey key: String) -> Bool {
        self.state.withLock { state in
            state.memoryCache[key] = nil
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
