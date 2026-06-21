import MicroRIBs
import FeatureAddArchiveInterface
import MSDomain
import TrackSearchDomain

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

	public func routeToSearch(searchTracksUseCase: SearchTracksUseCase, onSelect: @escaping (Track) -> Void) {
		let searchVC = ArchiveTrackSearchViewController(searchTracksUseCase: searchTracksUseCase, onSelect: onSelect)
		searchVC.modalPresentationStyle = .pageSheet
		viewController.uiviewController.present(searchVC, animated: true)
	}
}
