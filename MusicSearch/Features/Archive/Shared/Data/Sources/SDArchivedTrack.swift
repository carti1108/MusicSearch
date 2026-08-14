//
//  SDArchivedTrack.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import SwiftData
import ArchiveDomain

@Model
public final class SDArchivedTrack {
	@Attribute(.unique) public var id: UUID
	public var platformIDs: [String: String]
	public var coverImageData: Data?
	public var title: String
	public var artist: String
	public var genres: [String]
	public var label: String
	public var releaseDate: Date?
	public var listenDate: Date
	public var rating: Double
	public var memo: String?
	public var albumTitle: String?
	public var distributor: String?
	public var albumType: String?
	public var isIntroGood: Bool
	public var isGoodUntilMiddle: Bool
	public var isGoodUntilEnd: Bool

	public init(
		id: UUID = UUID(),
		platformIDs: [String: String] = [:],
		coverImageData: Data? = nil,
		title: String,
		artist: String,
		genres: [String] = [],
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
		self.genres = genres
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

	public func toDomain() -> ArchivedTrack {
		return ArchivedTrack(
			id: id,
			platformIDs: platformIDs,
			coverImageData: coverImageData,
			title: title,
			artist: artist,
			genres: genres,
			label: label,
			releaseDate: releaseDate,
			listenDate: listenDate,
			rating: rating,
			memo: memo,
			albumTitle: albumTitle,
			distributor: distributor,
			albumType: albumType,
			isIntroGood: isIntroGood,
			isGoodUntilMiddle: isGoodUntilMiddle,
			isGoodUntilEnd: isGoodUntilEnd
		)
	}

	public convenience init(from domain: ArchivedTrack) {
		self.init(
			id: domain.id,
			platformIDs: domain.platformIDs,
			coverImageData: domain.coverImageData,
			title: domain.title,
			artist: domain.artist,
			genres: domain.genres,
			label: domain.label,
			releaseDate: domain.releaseDate,
			listenDate: domain.listenDate,
			rating: domain.rating,
			memo: domain.memo,
			albumTitle: domain.albumTitle,
			distributor: domain.distributor,
			albumType: domain.albumType,
			isIntroGood: domain.isIntroGood,
			isGoodUntilMiddle: domain.isGoodUntilMiddle,
			isGoodUntilEnd: domain.isGoodUntilEnd
		)
	}
}
