import Foundation
import Testing
@testable import FeatureArchive
import FeatureArchiveTesting
import ArchiveTesting
import ArchiveDomain

@MainActor
struct ArchiveInteractorTests {

	@Test("viewDidLoad 호출 시 트랙을 불러와서 State를 업데이트하는가")
	func viewDidLoadFetchesTracks() async {
		// Given
		let presenter = ArchivePresentableSpy()
		let repository = MockArchiveRepository()
		
		let mockTrack = ArchivedTrack(
			id: UUID(),
			title: "Test Track",
			artist: "Test Artist",
			imageURL: nil,
			rating: 4.5,
			review: "Great",
			genres: ["Pop"],
			releaseDate: Date(),
			listenedDate: Date()
		)
		repository.fetchArchivedTracksResult = [mockTrack]

		let interactor = ArchiveInteractor(
			presenter: presenter,
			archiveRepository: repository
		)

		// When
		interactor.viewDidLoad()
		
		// Then (Wait for async task)
		try? await Task.sleep(nanoseconds: 100_000_000)
		
		#expect(repository.fetchArchivedTracksCallCount == 1)
		#expect(presenter.updatedStateCallCount > 0)
		#expect(presenter.lastUpdatedState?.recentTracks.first?.title == "Test Track")
	}

	@Test("onAddTapped 시 라우터의 routeToAddArchive를 호출하는가")
	func onAddTappedRoutesToAddArchive() {
		// Given
		let presenter = ArchivePresentableSpy()
		let repository = MockArchiveRepository()
		let router = MockArchiveRouting()
		let interactor = ArchiveInteractor(presenter: presenter, archiveRepository: repository)
		interactor.router = router

		// When
		interactor.request(action: .onAddTapped)

		// Then
		#expect(router.routeToAddArchiveCallCount == 1)
	}

	@Test("didCloseAddArchive 시 라우터의 detachAddArchive를 호출하고 트랙을 다시 불러오는가")
	func didCloseAddArchiveDetachesAndRefetches() async {
		// Given
		let presenter = ArchivePresentableSpy()
		let repository = MockArchiveRepository()
		let router = MockArchiveRouting()
		let interactor = ArchiveInteractor(presenter: presenter, archiveRepository: repository)
		interactor.router = router

		// When
		interactor.didCloseAddArchive()
		try? await Task.sleep(nanoseconds: 100_000_000)

		// Then
		#expect(router.detachAddArchiveCallCount == 1)
		#expect(repository.fetchArchivedTracksCallCount == 1)
	}

	@Test("onDeleteTapped 시 repository를 통해 트랙을 삭제하고 다시 불러오는가")
	func onDeleteTappedDeletesAndRefetches() async {
		// Given
		let presenter = ArchivePresentableSpy()
		let repository = MockArchiveRepository()
		let interactor = ArchiveInteractor(presenter: presenter, archiveRepository: repository)
		
		let mockTrack = ArchivedTrack(
			id: UUID(),
			title: "Test Track",
			artist: "Test Artist",
			imageURL: nil,
			rating: 4.5,
			review: "Great",
			genres: [],
			releaseDate: Date(),
			listenedDate: Date()
		)

		// When
		interactor.request(action: .onDeleteTapped(track: mockTrack))
		try? await Task.sleep(nanoseconds: 100_000_000)

		// Then
		#expect(repository.deleteArchivedTrackCallCount == 1)
		#expect(repository.lastDeletedTrackId == mockTrack.id)
		#expect(repository.fetchArchivedTracksCallCount == 1)
	}
}
