import MicroRIBs
import FeatureArchiveSearchInterface



final class ArchiveSearchRouter: ViewableRouter<ArchiveSearchInteractable, ArchiveSearchViewControllable>, ArchiveSearchRouting {

    override init(interactor: ArchiveSearchInteractable, viewController: ArchiveSearchViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
