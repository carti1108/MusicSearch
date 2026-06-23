import Foundation
import SwiftData
import ArchiveDomain

@MainActor
public final class ArchiveRepositoryImpl: ArchiveRepository {
	private let modelContext: ModelContext

	public init(modelContext: ModelContext) {
		self.modelContext = modelContext
	}

	public func fetchArchivedTracks() async throws -> [ArchivedTrack] {
		let descriptor = FetchDescriptor<SDArchivedTrack>(sortBy: [SortDescriptor(\.listenDate, order: .reverse)])
		let tracks = try modelContext.fetch(descriptor)
		return tracks.map { $0.toDomain() }
	}

	public func addArchivedTrack(_ track: ArchivedTrack) async throws {
		let sdTrack = SDArchivedTrack(from: track)
		modelContext.insert(sdTrack)
		try modelContext.save()
	}

	public func updateArchivedTrack(_ track: ArchivedTrack) async throws {
		let id = track.id
		let descriptor = FetchDescriptor<SDArchivedTrack>(predicate: #Predicate { $0.id == id })
		if let existingTrack = try modelContext.fetch(descriptor).first {
			existingTrack.platformIDs = track.platformIDs
			existingTrack.coverImageData = track.coverImageData
			existingTrack.title = track.title
			existingTrack.artist = track.artist
			existingTrack.genre = track.genre
			existingTrack.label = track.label
			existingTrack.releaseDate = track.releaseDate
			existingTrack.listenDate = track.listenDate
			existingTrack.rating = track.rating
			existingTrack.memo = track.memo
			existingTrack.albumTitle = track.albumTitle
			existingTrack.distributor = track.distributor
			existingTrack.albumType = track.albumType
			existingTrack.isIntroGood = track.isIntroGood
			existingTrack.isGoodUntilMiddle = track.isGoodUntilMiddle
			existingTrack.isGoodUntilEnd = track.isGoodUntilEnd
			
			try modelContext.save()
		} else {
			// If it doesn't exist, insert it
			try await addArchivedTrack(track)
		}
	}

	public func deleteArchivedTrack(id: UUID) async throws {
		let descriptor = FetchDescriptor<SDArchivedTrack>(predicate: #Predicate { $0.id == id })
		if let trackToDelete = try modelContext.fetch(descriptor).first {
			modelContext.delete(trackToDelete)
			try modelContext.save()
		}
	}
}
