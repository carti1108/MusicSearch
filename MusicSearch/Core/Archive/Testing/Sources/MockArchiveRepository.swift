import Foundation
import ArchiveDomain

public final class MockArchiveRepository: ArchiveRepository, @unchecked Sendable {
	public init() {}

	public var fetchArchivedTracksCallCount = 0
	public var fetchArchivedTracksResult: [ArchivedTrack] = []
	public func fetchArchivedTracks() async throws -> [ArchivedTrack] {
		fetchArchivedTracksCallCount += 1
		return fetchArchivedTracksResult
	}

	public var addArchivedTrackCallCount = 0
	public var lastAddedTrack: ArchivedTrack?
	public func addArchivedTrack(_ track: ArchivedTrack) async throws {
		addArchivedTrackCallCount += 1
		lastAddedTrack = track
	}

	public var deleteArchivedTrackCallCount = 0
	public var lastDeletedTrackId: UUID?
	public func deleteArchivedTrack(id: UUID) async throws {
		deleteArchivedTrackCallCount += 1
		lastDeletedTrackId = id
	}
}
