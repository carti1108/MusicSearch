import Foundation
import Testing
@testable import FeatureArchiveFolder
import FeatureArchiveFolderTesting

@MainActor
struct ArchiveFolderInteractorTests {

    @Test("onCloseTapped 시 listener의 archiveFolderDidTapClose를 호출하는가")
    func onCloseTappedCallsListener() {
        // Given
        let presenter = ArchiveFolderPresentableSpy()
        let listener = ArchiveFolderListenerMock()
        
        let interactor = ArchiveFolderInteractor(
            presenter: presenter
        )
        interactor.listener = listener

        // When
        interactor.request(action: .onCloseTapped)

        // Then
        #expect(listener.didCloseArchiveFolderCallCount == 1)
    }
}
