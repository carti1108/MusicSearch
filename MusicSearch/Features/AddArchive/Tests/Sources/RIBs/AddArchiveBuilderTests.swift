import Foundation
import Testing
@testable import FeatureAddArchive
import MicroRIBs
import MSDomain

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
	var musicAppRepository: any MSDomain.MusicAppRepository {
		MockMusicAppRepositoryForBuilder()
	}
}

final class MockArchiveRepositoryForBuilder: ArchiveDomain.ArchiveRepository, @unchecked Sendable {
	func fetchArchivedTracks() async throws -> [ArchiveDomain.ArchivedTrack] { [] }
	func addArchivedTrack(_ track: ArchiveDomain.ArchivedTrack) async throws {}
	func deleteArchivedTrack(id: UUID) async throws {}
}

final class MockMusicAppRepositoryForBuilder: MSDomain.MusicAppRepository, @unchecked Sendable {
	func fetchDeepLink(for track: Track) async -> URL? { return nil }
	func fetchDeepLink(for artist: String) async -> URL? { return nil }
	func searchSpotifyTracks(query: String, limit: Int, offset: Int) async throws -> (tracks: [MSDomain.Track], totalResults: Int) {
		return (tracks: [], totalResults: 0)
	}
}

final class MockAddArchiveListener: AddArchiveListener {
	func didCloseAddArchive() {}
}
