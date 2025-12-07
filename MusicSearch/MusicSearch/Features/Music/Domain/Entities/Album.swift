//
//  Album.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public struct Album: Identifiable, Equatable {
	public let id: String
	public let title: String
	public let artist: String
	public let imageURL: URL?
	public let releaseDate: Date?
	public let playCount: Int?

	public init(
		id: String = UUID().uuidString,
		title: String,
		artist: String,
		imageURL: URL?,
		releaseDate: Date? = nil,
		playCount: Int? = nil
	) {
		self.id = id
		self.title = title
		self.artist = artist
		self.imageURL = imageURL
		self.releaseDate = releaseDate
		self.playCount = playCount
	}
}
