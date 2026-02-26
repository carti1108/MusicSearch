//
//  Track.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public struct Track: Identifiable, Equatable, Sendable, Hashable {
	public let id: String
	public let mbid: String?
	public let title: String
	public let artist: String
	public let imageURL: URL?

	public init(
		id: String = UUID().uuidString,
		mbid: String? = nil,
		title: String,
		artist: String,
		imageURL: URL?
	) {
		self.id = id
		self.mbid = mbid
		self.title = title
		self.artist = artist
		self.imageURL = imageURL
	}
}
