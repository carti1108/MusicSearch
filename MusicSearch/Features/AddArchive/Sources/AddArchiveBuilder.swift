import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import FeatureAddArchiveInterface
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
}

public protocol AddArchiveInteractable: Interactable {
	var router: AddArchiveRouting? { get set }
	var listener: AddArchiveListener? { get set }
}

public final class AddArchiveWrapperInteractor: Interactor, AddArchiveInteractable {
	public weak var router: AddArchiveRouting?
	public weak var listener: AddArchiveListener?
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
					}
				}
			)
		}
		
		let view = AddArchiveView(store: store)
		let viewController = AddArchiveHostingController(rootView: view, interactor: interactor)
		viewController.view.backgroundColor = .clear
		
		let router = AddArchiveWrapperRouter(
			interactor: interactor,
			viewController: viewController
		)
		interactor.router = router
		
		return router
	}
}
