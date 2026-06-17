import Foundation
import Testing
@testable import FeatureArchive
import MicroRIBs

@MainActor
struct ArchiveBuilderTests {

	@Test("build 호출 시 ArchiveRouting을 반환하는가")
	func buildReturnsRouting() {
		// Given
		let component = ArchiveComponent(dependency: MockArchiveDependency())
		let builder = ArchiveBuilder(dependency: component)

		// When
		let router = builder.build(withListener: MockArchiveListener())

		// Then
		#expect(router != nil)
		#expect(router is ArchiveRouting)
	}
}

final class MockArchiveDependency: ArchiveDependency {
	var archiveRepository: any ArchiveDomain.ArchiveRepository {
		MockArchiveRepositoryForBuilder()
	}
}

final class MockArchiveRepositoryForBuilder: ArchiveDomain.ArchiveRepository, @unchecked Sendable {
	func fetchArchivedTracks() async throws -> [ArchiveDomain.ArchivedTrack] { [] }
	func addArchivedTrack(_ track: ArchiveDomain.ArchivedTrack) async throws {}
	func deleteArchivedTrack(id: UUID) async throws {}
}

final class MockArchiveListener: ArchiveListener {}
