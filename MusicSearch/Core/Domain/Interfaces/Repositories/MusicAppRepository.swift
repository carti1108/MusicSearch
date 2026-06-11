//
//  MusicAppRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation

public protocol MusicAppRepository: Sendable {
	func fetchDeepLink(for track: Track) async -> URL?
	func fetchDeepLink(for artist: String) async -> URL?
}
