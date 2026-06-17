import Foundation
import Testing
@testable import FeatureSettings
import FeatureSettingsTesting

@MainActor
struct SettingsInteractorTests {

    @Test("onCloseTapped 시 listener의 settingsDidTapClose를 호출하는가")
    func onCloseTappedCallsListener() {
        // Given
        let presenter = SettingsPresentableSpy()
        let listener = SettingsListenerMock()
        
        let interactor = SettingsInteractor(
            presenter: presenter
        )
        interactor.listener = listener

        // When
        interactor.request(action: .onCloseTapped)

        // Then
        #expect(listener.didCloseSettingsCallCount == 1)
    }
}
