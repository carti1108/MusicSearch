import Foundation

public struct ArchivedTrack: Equatable, Identifiable, Sendable {
	public let id: UUID
	public let coverImageData: Data?
	public let title: String
	public let artist: String
	public let genre: String
	public let label: String
	public let releaseDate: Date?
	public let listenDate: Date
	public let rating: Double
	public let memo: String?

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
}
