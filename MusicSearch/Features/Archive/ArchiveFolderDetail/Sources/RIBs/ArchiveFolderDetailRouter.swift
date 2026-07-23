import MicroRIBs
import FeatureArchiveFolderDetailInterface
import ArchiveDomain

@MainActor
public protocol ArchiveFolderDetailInteractable: Interactable, ArchiveFolderDetailListener {
    var router: ArchiveFolderDetailRouting? { get set }
    var listener: ArchiveFolderDetailListener? { get set }
}

@MainActor
public protocol ArchiveFolderDetailViewControllable: ViewControllable {
}

public final class ArchiveFolderDetailRouter: ViewableRouter<ArchiveFolderDetailInteractable, ArchiveFolderDetailViewControllable>, ArchiveFolderDetailRouting {
    override init(interactor: ArchiveFolderDetailInteractable, viewController: ArchiveFolderDetailViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    public func routeToFolderDetail(folderItem: FolderItem) {}
    public func detachFolderDetail(popUI: Bool) {}
}
