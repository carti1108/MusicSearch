import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import FeatureAddArchiveInterface
import FeatureArchiveTrackSearchInterface
import ArchiveDomain
import TrackSearchDomain
import MSDomain

final class AddArchiveComponent: Component<AddArchiveDependency> {
	fileprivate var archiveRepository: ArchiveRepository {
		return dependency.archiveRepository
	}
	fileprivate var searchTracksUseCase: SearchTracksUseCase {
		return dependency.searchTracksUseCase
	}
	fileprivate var imageDownloadRepository: ImageDownloadRepository {
		return dependency.imageDownloadRepository
	}
	fileprivate var archiveTrackSearchBuilder: ArchiveTrackSearchBuildable {
		return dependency.archiveTrackSearchBuilder
	}
}

public protocol AddArchiveInteractable: Interactable, ArchiveTrackSearchListener {
	var router: AddArchiveRouting? { get set }
	var listener: AddArchiveListener? { get set }
}

public final class AddArchiveWrapperInteractor: Interactor, AddArchiveInteractable {
	public weak var router: AddArchiveRouting?
	public weak var listener: AddArchiveListener?
	
	var onTrackSelected: ((Track) -> Void)?
	
	// MARK: - ArchiveTrackSearchListener
	public func archiveTrackSearchDidClose() {
		router?.detachArchiveTrackSearch()
	}
	
	public func archiveTrackSearchDidSelectTrack(_ track: Track) {
		onTrackSelected?(track)
		router?.detachArchiveTrackSearch()
	}
}

public final class AddArchiveHostingController: UIHostingController<AddArchiveView>, ViewControllable, UIAdaptivePresentationControllerDelegate {
	public var uiviewController: UIViewController { self }
	private weak var interactor: AddArchiveWrapperInteractor?

	init(rootView: AddArchiveView, interactor: AddArchiveWrapperInteractor) {
		self.interactor = interactor
		super.init(rootView: rootView)
		self.presentationController?.delegate = self
	}
	
	@MainActor required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		interactor?.listener?.didCloseAddArchive()
	}
}

public final class AddArchiveWrapperRouter: ViewableRouter<AddArchiveInteractable, ViewControllable>, AddArchiveRouting {
	private let archiveTrackSearchBuilder: ArchiveTrackSearchBuildable
	private var archiveTrackSearchRouting: ArchiveTrackSearchRouting?

	init(
		interactor: AddArchiveInteractable,
		viewController: ViewControllable,
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

public final class AddArchiveBuilder: Builder<AddArchiveDependency>, AddArchiveBuildable {
	public override init(dependency: AddArchiveDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: AddArchiveListener, editTrack: ArchivedTrack? = nil) -> AddArchiveRouting {
		let component = AddArchiveComponent(dependency: dependency)
		
		let interactor = AddArchiveWrapperInteractor()
		interactor.listener = listener
		
		let store = Store(initialState: AddArchiveFeature.State(editTrack: editTrack)) {
			AddArchiveFeature(
				archiveRepository: component.archiveRepository,
				searchTracksUseCase: component.searchTracksUseCase,
				imageDownloadRepository: component.imageDownloadRepository,
				onDelegate: { [weak interactor] action in
					switch action {
					case .didCloseAddArchive:
						interactor?.listener?.didCloseAddArchive()
					case .didTapSearchTrack:
						interactor?.router?.routeToArchiveTrackSearch()
					}
				}
			)
		}
		
		interactor.onTrackSelected = { track in
			store.send(.trackSelected(track))
		}
		
		let view = AddArchiveView(store: store)
		let viewController = AddArchiveHostingController(rootView: view, interactor: interactor)
		viewController.view.backgroundColor = .clear
		
		let router = AddArchiveWrapperRouter(
			interactor: interactor,
			viewController: viewController,
			archiveTrackSearchBuilder: component.archiveTrackSearchBuilder
		)
		interactor.router = router
		
		return router
	}
}
