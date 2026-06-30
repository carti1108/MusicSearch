import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import FeatureArchiveTrackSearchInterface
import TrackSearchDomain
import MSDomain

@MainActor
public protocol ArchiveTrackSearchDependency: MicroRIBs.Dependency {
	var searchTracksUseCase: SearchTracksUseCase { get }
}

final class ArchiveTrackSearchComponent: Component<ArchiveTrackSearchDependency> {
	fileprivate var searchTracksUseCase: SearchTracksUseCase {
		return dependency.searchTracksUseCase
	}
}

public protocol ArchiveTrackSearchInteractable: Interactable {
	var router: ArchiveTrackSearchRouting? { get set }
	var listener: ArchiveTrackSearchListener? { get set }
}

public final class ArchiveTrackSearchWrapperInteractor: Interactor, ArchiveTrackSearchInteractable {
	public weak var router: ArchiveTrackSearchRouting?
	public weak var listener: ArchiveTrackSearchListener?
}

public final class ArchiveTrackSearchHostingController: UIHostingController<ArchiveTrackSearchView>, ViewControllable, UIAdaptivePresentationControllerDelegate {
	public var uiviewController: UIViewController { self }
	private weak var interactor: ArchiveTrackSearchWrapperInteractor?

	init(rootView: ArchiveTrackSearchView, interactor: ArchiveTrackSearchWrapperInteractor) {
		self.interactor = interactor
		super.init(rootView: rootView)
		self.presentationController?.delegate = self
	}
	
	@MainActor required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		interactor?.listener?.archiveTrackSearchDidClose()
	}
}

public final class ArchiveTrackSearchWrapperRouter: ViewableRouter<ArchiveTrackSearchInteractable, ViewControllable>, ArchiveTrackSearchRouting {
}

public final class ArchiveTrackSearchBuilder: Builder<ArchiveTrackSearchDependency>, ArchiveTrackSearchBuildable {
	public override init(dependency: ArchiveTrackSearchDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: ArchiveTrackSearchListener) -> ArchiveTrackSearchRouting {
		let component = ArchiveTrackSearchComponent(dependency: dependency)
		
		let interactor = ArchiveTrackSearchWrapperInteractor()
		interactor.listener = listener
		
		let store = Store(initialState: ArchiveTrackSearchFeature.State()) {
			ArchiveTrackSearchFeature(
				searchTracksUseCase: component.searchTracksUseCase,
				onDelegate: { [weak interactor] action in
					switch action {
					case let .trackSelected(track):
						interactor?.listener?.archiveTrackSearchDidSelectTrack(track)
					}
				}
			)
		}
		
		let view = ArchiveTrackSearchView(store: store)
		let viewController = ArchiveTrackSearchHostingController(rootView: view, interactor: interactor)
		viewController.view.backgroundColor = .clear
		
		let router = ArchiveTrackSearchWrapperRouter(
			interactor: interactor,
			viewController: viewController
		)
		interactor.router = router
		
		return router
	}
}
