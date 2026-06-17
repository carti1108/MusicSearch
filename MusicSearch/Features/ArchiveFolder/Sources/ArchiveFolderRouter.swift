import MicroRIBs
import FeatureArchiveFolderInterface

final class ArchiveFolderRouter: ViewableRouter<ArchiveFolderInteractable, ArchiveFolderViewControllable>, ArchiveFolderRouting {

    override init(interactor: ArchiveFolderInteractable, viewController: ArchiveFolderViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
