import Foundation
import Testing
import MicroRIBs
@testable import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailTesting
import ArchiveDomain
import ArchiveTesting

@MainActor
struct ArchiveFolderDetailRouterTests {

    @Test("routeToFolderDetail 호출 시 자식 라우터를 빌드하고 push하는가")
    func routeToFolderDetailBuildsAndPushes() {
        // Given
        let interactor = MockArchiveFolderDetailInteractable()
        let viewController = MockArchiveFolderDetailViewControllable()
        let builder = MockArchiveFolderDetailBuildable()
        
        let childRouter = MockArchiveFolderDetailRouting(interactor: MockArchiveFolderDetailInteractable(), viewController: MockArchiveFolderDetailViewControllable())
        builder.buildResult = childRouter
        
        let router = ArchiveFolderDetailRouter(
            interactor: interactor,
            viewController: viewController,
            detailBuilder: builder
        )
        
        let folderItem = FolderItem(title: "Child", subtitle: "", type: .custom)

        // When
        router.routeToFolderDetail(folderItem: folderItem)

        // Then
        #expect(builder.buildCallCount == 1)
        #expect(builder.lastFolderItem?.title == "Child")
        #expect(viewController.pushCallCount == 1)
        #expect(router.children.count == 1)
    }

    @Test("detachFolderDetail 호출 시 자식 라우터를 분리하고 pop하는가")
    func detachFolderDetailDetachesAndPops() {
        // Given
        let interactor = MockArchiveFolderDetailInteractable()
        let viewController = MockArchiveFolderDetailViewControllable()
        let builder = MockArchiveFolderDetailBuildable()
        
        let childRouter = MockArchiveFolderDetailRouting(interactor: MockArchiveFolderDetailInteractable(), viewController: MockArchiveFolderDetailViewControllable())
        builder.buildResult = childRouter
        
        let router = ArchiveFolderDetailRouter(
            interactor: interactor,
            viewController: viewController,
            detailBuilder: builder
        )
        
        let folderItem = FolderItem(title: "Child", subtitle: "", type: .custom)
        router.routeToFolderDetail(folderItem: folderItem)

        // When
        router.detachFolderDetail()

        // Then
        #expect(viewController.popCallCount == 1)
        #expect(router.children.isEmpty)
    }
}

// Dummy Mock for Interactable to pass to Router
final class MockArchiveFolderDetailInteractable: ArchiveFolderDetailInteractable {
    var router: ArchiveFolderDetailRouting?
    var listener: ArchiveFolderDetailListener?
    var isActive: Bool = true
    var isActiveStream: MicroRIBs.Observable<Bool> = MicroRIBs.Observable.just(true)
    
    func activate() {}
    func deactivate() {}
    func archiveFolderDetailDidTapClose() {}
}
