import MicroRIBs
import FeatureAddArchiveInterface
import FeatureArchiveTrackSearchInterface

@MainActor
public protocol AddArchiveInteractable: Interactable, ArchiveTrackSearchListener {
	var router: AddArchiveRouting? { get set }
	var listener: AddArchiveListener? { get set }
}

@MainActor
public protocol AddArchiveViewControllable: ViewControllable {
}

public final class AddArchiveRouter: ViewableRouter<AddArchiveInteractable, AddArchiveViewControllable>, AddArchiveRouting {
	private let archiveTrackSearchBuilder: ArchiveTrackSearchBuildable
	private var archiveTrackSearchRouting: ArchiveTrackSearchRouting?

	init(
		interactor: AddArchiveInteractable,
		viewController: AddArchiveViewControllable,
		archiveTrackSearchBuilder: ArchiveTrackSearchBuildable
	) {
		self.archiveTrackSearchBuilder = archiveTrackSearchBuilder
		super.init(interactor: interactor, viewController: viewController)
	}

	public func routeToArchiveTrackSearch() {
		guard archiveTrackSearchRouting == nil else { return }
		let router = archiveTrackSearchBuilder.build(withListener: interactor)
		self.archiveTrackSearchRouting = router
		attachChild(router)
		viewController.uiviewController.present(router.viewControllable.uiviewController, animated: true)
	}

	public func detachArchiveTrackSearch() {
		guard let router = archiveTrackSearchRouting else { return }
		viewController.uiviewController.dismiss(animated: true)
		detachChild(router)
		self.archiveTrackSearchRouting = nil
	}
}
