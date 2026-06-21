import Foundation
import Testing
@testable import FeatureArchiveFolder
import FeatureArchiveFolderTesting
import ArchiveDomain
import ArchiveTesting

@MainActor
struct ArchiveFolderBuilderTests {

    @Test("build 시 listener와 presenter가 정상 연결되고 의존성이 주입되는가")
    func buildWiresListenerPresenterAndDependencies() {
        // Given
        let dependency = MockArchiveFolderDependency(
            archiveRepository: MockArchiveRepository(),
            archiveFolderDetailBuilder: MockArchiveFolderDetailBuildableForFolder()
        )
        let builder = ArchiveFolderBuilder(dependency: dependency)
        let listener = ArchiveFolderListenerMock()

        // When
        let routing = builder.build(withListener: listener)

        // Then
        #expect(routing is ArchiveFolderRouter)
        guard let router = routing as? ArchiveFolderRouter else {
            Issue.record("Router 타입이 일치하지 않습니다.")
            return
        }
        guard let interactor = router.interactor as? ArchiveFolderInteractor else {
            Issue.record("Interactor가 조립되지 않았습니다.")
            return
        }
        guard let viewController = router.viewControllable as? ArchiveFolderViewController else {
            Issue.record("ViewController가 조립되지 않았습니다.")
            return
        }

        #expect(interactor.listener === listener)
        #expect(viewController.listener === interactor)
    }
}
