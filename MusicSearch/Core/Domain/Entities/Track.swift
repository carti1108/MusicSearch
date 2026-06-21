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
	public let albumTitle: String?
	public let albumType: String?
	public let releaseDate: Date?

	public init(
		id: String = UUID().uuidString,
		mbid: String? = nil,
		title: String,
		artist: String,
		imageURL: URL?,
		albumTitle: String? = nil,
		albumType: String? = nil,
		releaseDate: Date? = nil
	) {
		self.id = id
		self.mbid = mbid
		self.title = title
		self.artist = artist
		self.imageURL = imageURL
		self.albumTitle = albumTitle
		self.albumType = albumType
		self.releaseDate = releaseDate
	}
}
