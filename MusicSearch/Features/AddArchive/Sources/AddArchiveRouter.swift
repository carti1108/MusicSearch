import MicroRIBs
import FeatureAddArchiveInterface

public protocol AddArchiveInteractable: Interactable {
	var router: AddArchiveRouting? { get set }
	var listener: AddArchiveListener? { get set }
}

public protocol AddArchiveViewControllable: ViewControllable {
}

public final class AddArchiveRouter: ViewableRouter<AddArchiveInteractable, AddArchiveViewControllable>, AddArchiveRouting {


	public override init(interactor: AddArchiveInteractable, viewController: AddArchiveViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
