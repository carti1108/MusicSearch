import Foundation
import Testing
@testable import FeatureAddArchive
import MicroRIBs

@MainActor
struct AddArchiveBuilderTests {

	@Test("build 호출 시 AddArchiveRouting을 반환하는가")
	func buildReturnsRouting() {
		// Given
		let component = AddArchiveComponent(dependency: MockAddArchiveDependency())
		let builder = AddArchiveBuilder(dependency: component)

		// When
		let router = builder.build(withListener: MockAddArchiveListener())

		// Then
		#expect(router != nil)
		#expect(router is AddArchiveRouting)
	}
}

final class MockAddArchiveDependency: AddArchiveDependency {
	var archiveRepository: any ArchiveDomain.ArchiveRepository {
		MockArchiveRepositoryForBuilder()
	}
}

final class MockArchiveRepositoryForBuilder: ArchiveDomain.ArchiveRepository, @unchecked Sendable {
	func fetchArchivedTracks() async throws -> [ArchiveDomain.ArchivedTrack] { [] }
	func addArchivedTrack(_ track: ArchiveDomain.ArchivedTrack) async throws {}
	func deleteArchivedTrack(id: UUID) async throws {}
}

final class MockAddArchiveListener: AddArchiveListener {
	func didCloseAddArchive() {}
}
