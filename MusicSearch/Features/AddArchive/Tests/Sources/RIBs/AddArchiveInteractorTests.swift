import Foundation
import Testing
@testable import FeatureAddArchive
import FeatureAddArchiveTesting
import ArchiveTesting
import ArchiveDomain

@MainActor
struct AddArchiveInteractorTests {

	@Test("onCloseTapped 시 listener의 didCloseAddArchive를 호출하는가")
	func onCloseTappedCallsListener() {
		// Given
		let presenter = AddArchivePresentableSpy()
		let repository = MockArchiveRepository()
		let listener = AddArchiveListenerMock()
		
		let interactor = AddArchiveInteractor(
			presenter: presenter,
			archiveRepository: repository
		)
		interactor.listener = listener

		// When
		interactor.request(action: .onCloseTapped)

		// Then
		#expect(listener.didCloseAddArchiveCallCount == 1)
	}

	@Test("onSaveTapped 시 repository를 통해 트랙을 추가하고 listener를 호출하는가")
	func onSaveTappedAddsTrackAndCallsListener() async {
		// Given
		let presenter = AddArchivePresentableSpy()
		let repository = MockArchiveRepository()
		let listener = AddArchiveListenerMock()
		
		let interactor = AddArchiveInteractor(
			presenter: presenter,
			archiveRepository: repository
		)
		interactor.listener = listener

		let testDate = Date()
		let testImageData = Data()
		
		// When
		interactor.request(action: .onSaveTapped(
			title: "Title",
			artist: "Artist",
			rating: 5.0,
			review: "Great",
			genres: ["Pop"],
			releaseDate: testDate,
			listenedDate: testDate,
			imageData: testImageData
		))
		
		// Wait for async task to complete
		try? await Task.sleep(nanoseconds: 100_000_000)

		// Then
		#expect(repository.addArchivedTrackCallCount == 1)
		#expect(repository.lastAddedTrack?.title == "Title")
		#expect(repository.lastAddedTrack?.artist == "Artist")
		#expect(repository.lastAddedTrack?.rating == 5.0)
		#expect(repository.lastAddedTrack?.review == "Great")
		#expect(repository.lastAddedTrack?.genres == ["Pop"])
		#expect(listener.didCloseAddArchiveCallCount == 1)
	}
}
