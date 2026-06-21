import MicroRIBs
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import ArchiveDomain

final class ArchiveFolderRouter: ViewableRouter<ArchiveFolderInteractable, ArchiveFolderViewControllable>, ArchiveFolderRouting {

    private let detailBuilder: ArchiveFolderDetailBuildable
    private var detailRouter: ArchiveFolderDetailRouting?

    init(interactor: ArchiveFolderInteractable, viewController: ArchiveFolderViewControllable, detailBuilder: ArchiveFolderDetailBuildable) {
        self.detailBuilder = detailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func routeToFolderDetail(folderItem: FolderItem) {
        guard detailRouter == nil else { 
            return 
        }
        let router = detailBuilder.build(withListener: interactor, folderItem: folderItem)
        self.detailRouter = router
        attachChild(router)
        viewController.push(viewController: router.viewControllable, animated: true)
    }
    
    func detachFolderDetail() {
        guard let router = detailRouter else { return }
        viewController.pop(animated: true)
        detachChild(router)
        self.detailRouter = nil
    }
}

