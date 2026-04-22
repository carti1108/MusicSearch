//
//  ArtistImageRepository.swift
//  MusicSearch
//
//  Created by Codex on 4/22/26.
//

import Foundation

protocol ArtistImageRepository: Sendable {
	func fetchImageURL(for artistName: String) async throws -> URL?
}
