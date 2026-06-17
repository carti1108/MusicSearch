import Foundation

public protocol ArchiveRepository: Sendable {
	func fetchArchivedTracks() async throws -> [ArchivedTrack]
	func addArchivedTrack(_ track: ArchivedTrack) async throws
	func deleteArchivedTrack(id: UUID) async throws
}
