import Foundation
import Testing
@testable import FeatureArchiveFolder
import FeatureArchiveFolderTesting
import ArchiveDomain

@MainActor
struct ArchiveFolderRouterTests {

    @Test("routeToFolderDetail 호출 시 자식 라우터를 빌드하고 push하는가")
    func routeToFolderDetailBuildsAndPushes() {
        // Given
        let interactor = MockArchiveFolderInteractable()
        let viewController = MockArchiveFolderViewControllable()
        let builder = MockArchiveFolderDetailBuildableForFolder()
        
        let childRouter = MockArchiveFolderDetailRoutingForFolder(viewController: MockArchiveFolderViewControllable())
        builder.buildResult = childRouter
        
        let router = ArchiveFolderRouter(
            interactor: interactor,
            viewController: viewController,
            detailBuilder: builder
        )
        
        let folderItem = FolderItem(title: "Child", subtitle: "", type: .custom)

        // When
        router.routeToFolderDetail(folderItem: folderItem)

        // Then
        #expect(builder.buildCallCount == 1)
        #expect(viewController.pushCallCount == 1)
        #expect(router.children.count == 1)
    }

    @Test("detachFolderDetail 호출 시 자식 라우터를 분리하고 pop하는가")
    func detachFolderDetailDetachesAndPops() {
        // Given
        let interactor = MockArchiveFolderInteractable()
        let viewController = MockArchiveFolderViewControllable()
        let builder = MockArchiveFolderDetailBuildableForFolder()
        
        let childRouter = MockArchiveFolderDetailRoutingForFolder(viewController: MockArchiveFolderViewControllable())
        builder.buildResult = childRouter
        
        let router = ArchiveFolderRouter(
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
