//
//  ArchivedTrack.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation

public struct ArchivedTrack: Equatable, Identifiable, Sendable {
	public let id: UUID
	public let platformIDs: [String: String]
	public let coverImageData: Data?
	public let title: String
	public let artist: String
	public let genre: String
	public let label: String
	public let releaseDate: Date?
	public let listenDate: Date
	public let rating: Double
	public let memo: String?
	public let albumTitle: String?
	public let distributor: String?
	public let albumType: String?
	public let isIntroGood: Bool
	public let isGoodUntilMiddle: Bool
	public let isGoodUntilEnd: Bool

	public init(
		id: UUID = UUID(),
		platformIDs: [String: String] = [:],
		coverImageData: Data? = nil,
		title: String,
		artist: String,
		genre: String,
		label: String,
		releaseDate: Date? = nil,
		listenDate: Date = Date(),
		rating: Double,
		memo: String? = nil,
		albumTitle: String? = nil,
		distributor: String? = nil,
		albumType: String? = nil,
		isIntroGood: Bool = false,
		isGoodUntilMiddle: Bool = false,
		isGoodUntilEnd: Bool = false
	) {
		self.id = id
		self.platformIDs = platformIDs
		self.coverImageData = coverImageData
		self.title = title
		self.artist = artist
		self.genre = genre
		self.label = label
		self.releaseDate = releaseDate
		self.listenDate = listenDate
		self.rating = rating
		self.memo = memo
		self.albumTitle = albumTitle
		self.distributor = distributor
		self.albumType = albumType
		self.isIntroGood = isIntroGood
		self.isGoodUntilMiddle = isGoodUntilMiddle
		self.isGoodUntilEnd = isGoodUntilEnd
	}
}
