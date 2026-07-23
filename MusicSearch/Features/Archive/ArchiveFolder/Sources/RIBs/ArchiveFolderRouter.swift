import MicroRIBs
import FeatureArchiveFolderInterface
import ArchiveDomain
import FeatureArchiveFolderDetailInterface

@MainActor
public protocol ArchiveFolderInteractable: Interactable, ArchiveFolderDetailListener {
    var router: ArchiveFolderRouting? { get set }
    var listener: ArchiveFolderListener? { get set }
}

@MainActor
public protocol ArchiveFolderViewControllable: ViewControllable {
}

public final class ArchiveFolderRouter: ViewableRouter<ArchiveFolderInteractable, ArchiveFolderViewControllable>, ArchiveFolderRouting {
    private let detailBuilder: ArchiveFolderDetailBuildable
    private var detailRouters: [ArchiveFolderDetailRouting] = []

    init(interactor: ArchiveFolderInteractable, viewController: ArchiveFolderViewControllable, detailBuilder: ArchiveFolderDetailBuildable) {
        self.detailBuilder = detailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    public func routeToFolderDetail(folderItem: FolderItem) {
        let router = detailBuilder.build(withListener: interactor, folderItem: folderItem)
        detailRouters.append(router)
        attachChild(router)
        viewController.uiviewController.navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
    }

    public func detachFolderDetail(popUI: Bool) {
        guard let router = detailRouters.popLast() else { return }
        if popUI {
            viewController.uiviewController.navigationController?.popViewController(animated: true)
        }
        detachChild(router)
    }
}
