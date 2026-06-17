import Foundation
import SwiftData
import ArchiveDomain

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

	public func deleteArchivedTrack(id: UUID) async throws {
		let descriptor = FetchDescriptor<SDArchivedTrack>(predicate: #Predicate { $0.id == id })
		if let trackToDelete = try modelContext.fetch(descriptor).first {
			modelContext.delete(trackToDelete)
			try modelContext.save()
		}
	}
}
