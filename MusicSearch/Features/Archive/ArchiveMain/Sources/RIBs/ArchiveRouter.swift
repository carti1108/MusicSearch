import MicroRIBs
import FeatureArchiveInterface

public final class ArchiveRouter: ViewableRouter<ArchiveInteractable, ViewControllable>, ArchiveRouting {
    public override init(interactor: ArchiveInteractable, viewController: ViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
