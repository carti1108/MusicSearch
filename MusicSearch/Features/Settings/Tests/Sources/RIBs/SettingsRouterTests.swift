import Foundation
import Testing
@testable import FeatureSettings
import FeatureSettingsTesting
import MSDomain

@MainActor
struct SettingsRouterTests {

    @Test("Router 초기화 시 의존성이 정상 설정되는가")
    func routerInitialization() {
        // Given
        let interactor = MockSettingsInteractable()
        let viewController = MockSettingsViewControllable()
        
        // When
        let router = SettingsRouter(interactor: interactor, viewController: viewController)

        // Then
        #expect(router.interactor === interactor)
        #expect(router.viewControllable === viewController)
        #expect(router.children.isEmpty)
    }
}
