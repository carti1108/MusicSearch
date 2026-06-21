import Foundation
import Testing
@testable import FeatureAddArchive
import FeatureAddArchiveTesting
import ArchiveTesting
import ArchiveDomain
import FeatureTrackSearchTesting

@MainActor
struct AddArchiveInteractorTests {

	@Test("onCloseTapped 시 listener의 didCloseAddArchive를 호출하는가")
	func onCloseTappedCallsListener() {
		// Given
		let presenter = AddArchivePresentableSpy()
		let repository = MockArchiveRepository()
		let searchUseCase = MockSearchTracksUseCase()
		let listener = AddArchiveListenerMock()
		
		let interactor = AddArchiveInteractor(
			presenter: presenter,
			archiveRepository: repository,
			searchTracksUseCase: searchUseCase
		)
		interactor.listener = listener

		// When
		interactor.closeTapped()

		// Then
		#expect(listener.didCloseAddArchiveCallCount == 1)
	}

	@Test("onSaveTapped 시 repository를 통해 트랙을 추가하고 listener를 호출하는가")
	func onSaveTappedAddsTrackAndCallsListener() async {
		// Given
		let presenter = AddArchivePresentableSpy()
		let repository = MockArchiveRepository()
		let searchUseCase = MockSearchTracksUseCase()
		let listener = AddArchiveListenerMock()
		
		let interactor = AddArchiveInteractor(
			presenter: presenter,
			archiveRepository: repository,
			searchTracksUseCase: searchUseCase
		)
		interactor.listener = listener

		let testDate = Date()
		let testImageData = Data()
		
		// When
		interactor.saveTapped(
			title: "Title",
			artist: "Artist",
			genre: "Pop",
			label: "Label",
			rating: 5.0,
			memo: "Great",
			releaseDate: testDate,
			listenDate: testDate,
			coverImageData: testImageData,
			albumTitle: "Album",
			distributor: "Distributor",
			albumType: "정규",
			isIntroGood: true,
			isGoodUntilMiddle: true,
			isGoodUntilEnd: true,
			platformIDs: ["spotify": "123"]
		)
		
		// Wait for async task to complete
		try? await Task.sleep(nanoseconds: 100_000_000)

		// Then
		#expect(repository.addArchivedTrackCallCount == 1)
		#expect(repository.lastAddedTrack?.title == "Title")
		#expect(repository.lastAddedTrack?.artist == "Artist")
		#expect(repository.lastAddedTrack?.rating == 5.0)
		#expect(repository.lastAddedTrack?.memo == "Great")
		#expect(repository.lastAddedTrack?.genre == "Pop")
		#expect(listener.didCloseAddArchiveCallCount == 1)
	}
}
