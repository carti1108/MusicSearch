import Foundation
import SwiftData
import ArchiveDomain

@Model
public final class SDArchivedTrack {
	@Attribute(.unique) public var id: UUID
	public var coverImageData: Data?
	public var title: String
	public var artist: String
	public var genre: String
	public var label: String
	public var releaseDate: Date?
	public var listenDate: Date
	public var rating: Double
	public var memo: String?

	public init(
		id: UUID = UUID(),
		coverImageData: Data? = nil,
		title: String,
		artist: String,
		genre: String,
		label: String,
		releaseDate: Date? = nil,
		listenDate: Date = Date(),
		rating: Double,
		memo: String? = nil
	) {
		self.id = id
		self.coverImageData = coverImageData
		self.title = title
		self.artist = artist
		self.genre = genre
		self.label = label
		self.releaseDate = releaseDate
		self.listenDate = listenDate
		self.rating = rating
		self.memo = memo
	}

	public func toDomain() -> ArchivedTrack {
		return ArchivedTrack(
			id: id,
			coverImageData: coverImageData,
			title: title,
			artist: artist,
			genre: genre,
			label: label,
			releaseDate: releaseDate,
			listenDate: listenDate,
			rating: rating,
			memo: memo
		)
	}

	public convenience init(from domain: ArchivedTrack) {
		self.init(
			id: domain.id,
			coverImageData: domain.coverImageData,
			title: domain.title,
			artist: domain.artist,
			genre: domain.genre,
			label: domain.label,
			releaseDate: domain.releaseDate,
			listenDate: domain.listenDate,
			rating: domain.rating,
			memo: domain.memo
		)
	}
}
