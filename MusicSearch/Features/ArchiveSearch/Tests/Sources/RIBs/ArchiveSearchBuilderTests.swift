import Foundation
import Testing
@testable import FeatureArchiveSearch
import FeatureArchiveSearchTesting
import ArchiveDomain
import ArchiveTesting

@MainActor
struct ArchiveSearchBuilderTests {

    @Test("build 시 listener와 presenter가 정상 연결되고 의존성이 주입되는가")
    func buildWiresListenerPresenterAndDependencies() {
        // Given
        let dependency = MockArchiveSearchDependency(archiveRepository: MockArchiveRepository())
        let builder = ArchiveSearchBuilder(dependency: dependency)
        let listener = ArchiveSearchListenerMock()

        // When
        let routing = builder.build(withListener: listener)

        // Then
        #expect(routing is ArchiveSearchRouter)
        guard let router = routing as? ArchiveSearchRouter else {
            Issue.record("Router 타입이 일치하지 않습니다.")
            return
        }
        guard let interactor = router.interactor as? ArchiveSearchInteractor else {
            Issue.record("Interactor가 조립되지 않았습니다.")
            return
        }
        guard let viewController = router.viewControllable as? ArchiveSearchViewController else {
            Issue.record("ViewController가 조립되지 않았습니다.")
            return
        }

        #expect(interactor.listener === listener)
        #expect(viewController.listener === interactor)
    }
}
