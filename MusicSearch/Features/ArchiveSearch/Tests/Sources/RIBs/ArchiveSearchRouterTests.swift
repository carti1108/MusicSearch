import Foundation
import Testing
@testable import FeatureArchiveSearch
import FeatureArchiveSearchTesting
import ArchiveDomain

@MainActor
struct ArchiveSearchRouterTests {

    @Test("Router 초기화 시 의존성이 정상 설정되는가")
    func routerInitialization() {
        // Given
        let interactor = MockArchiveSearchInteractable()
        let viewController = MockArchiveSearchViewControllable()
        
        // When
        let router = ArchiveSearchRouter(interactor: interactor, viewController: viewController)

        // Then
        #expect(router.interactor === interactor)
        #expect(router.viewControllable === viewController)
        #expect(router.children.isEmpty)
    }
}
