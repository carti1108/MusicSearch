//
//  ArtistImageService.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation

public protocol ArtistImageService: Sendable {
	func fetchImageURL(for artistName: String) async throws -> URL?
}
