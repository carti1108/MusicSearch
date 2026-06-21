import Foundation
import Testing
import UIKit
@testable import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailTesting
import MSDomain
import ArchiveDomain
import ArchiveTesting

@MainActor
struct ArchiveFolderDetailBuilderTests {

    @Test("build 시 listener와 presenter가 정상 연결되고 의존성이 주입되는가")
    func buildWiresListenerPresenterAndDependencies() {
        // Given
        let dependency = MockArchiveFolderDetailDependency(
            archiveRepository: MockArchiveRepository(),
            exportToSpotifyUseCase: MockExportToSpotifyUseCase(),
            manageSpotifyAuthUseCase: MockManageSpotifyAuthUseCase()
        )
        let builder = ArchiveFolderDetailBuilder(dependency: dependency)
        let listener = MockArchiveFolderDetailListener()
        let folderItem = FolderItem(title: "Test", subtitle: "0", type: .custom)

        // When
        let routing = builder.build(withListener: listener, folderItem: folderItem)

        // Then
        #expect(routing is ArchiveFolderDetailRouter)
        guard let router = routing as? ArchiveFolderDetailRouter else {
            Issue.record("Router 타입이 일치하지 않습니다.")
            return
        }
        guard let interactor = router.interactor as? ArchiveFolderDetailInteractor else {
            Issue.record("Interactor가 조립되지 않았습니다.")
            return
        }
        guard let viewController = router.viewControllable as? ArchiveFolderDetailViewController else {
            Issue.record("ViewController가 조립되지 않았습니다.")
            return
        }

        #expect(interactor.listener === listener)
        #expect(viewController.listener === interactor)
    }
}
