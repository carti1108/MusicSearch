//
//  Track.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public struct Track: Identifiable, Equatable, Sendable {
	public let id: String
	public let title: String
	public let artist: String
	public let imageURL: URL?

	public init(
		id: String = UUID().uuidString,
		title: String,
		artist: String,
		imageURL: URL?
	) {
		self.id = id
		self.title = title
		self.artist = artist
		self.imageURL = imageURL
	}
}
