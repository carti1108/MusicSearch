//
//  KeychainService.swift
//  MusicSearch
//
//  Created by Kiseok on 7/29/26.
//

import Foundation

public protocol KeychainService: Sendable {
    func read(forKey key: String) -> String?
    func save(_ value: String, forKey key: String) -> Bool
    func delete(forKey key: String) -> Bool
}
