import MicroRIBs
import ArchiveDomain
import FeatureArchiveFolderDetailInterface

public protocol ArchiveFolderDetailInteractable: Interactable, ArchiveFolderDetailListener {
    var router: ArchiveFolderDetailRouting? { get set }
    var listener: ArchiveFolderDetailListener? { get set }
}

public protocol ArchiveFolderDetailViewControllable: ViewControllable {
    func push(viewController: ViewControllable, animated: Bool)
    func pop(animated: Bool)
}

public final class ArchiveFolderDetailRouter: ViewableRouter<ArchiveFolderDetailInteractable, ArchiveFolderDetailViewControllable>, ArchiveFolderDetailRouting {

    private let detailBuilder: ArchiveFolderDetailBuildable
    
    public init(interactor: ArchiveFolderDetailInteractable, viewController: ArchiveFolderDetailViewControllable, detailBuilder: ArchiveFolderDetailBuildable) {
        self.detailBuilder = detailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    
    private var childRouter: ArchiveFolderDetailRouting?
    
    public func routeToFolderDetail(folderItem: FolderItem) {
        guard childRouter == nil else { return }
        let router = detailBuilder.build(withListener: interactor, folderItem: folderItem)
        self.childRouter = router
        attachChild(router)
        viewController.push(viewController: router.viewControllable, animated: true)
    }
    
    public func detachFolderDetail() {
        if let child = childRouter {
            detachChild(child)
            viewController.pop(animated: true)
            self.childRouter = nil
        }
    }

}
