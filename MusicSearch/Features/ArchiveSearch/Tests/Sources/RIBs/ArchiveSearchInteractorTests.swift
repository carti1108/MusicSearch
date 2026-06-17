import Foundation
import Testing
@testable import FeatureArchiveSearch
import FeatureArchiveSearchTesting

@MainActor
struct ArchiveSearchInteractorTests {

    @Test("onCloseTapped 시 listener의 archiveSearchDidTapClose를 호출하는가")
    func onCloseTappedCallsListener() {
        // Given
        let presenter = ArchiveSearchPresentableSpy()
        let listener = ArchiveSearchListenerMock()
        
        let interactor = ArchiveSearchInteractor(
            presenter: presenter
        )
        interactor.listener = listener

        // When
        interactor.request(action: .onCloseTapped)

        // Then
        #expect(listener.didCloseArchiveSearchCallCount == 1)
    }
}
