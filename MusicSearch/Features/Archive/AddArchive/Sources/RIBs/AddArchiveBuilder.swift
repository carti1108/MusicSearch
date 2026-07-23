import Foundation
import MicroRIBs
import FeatureAddArchiveInterface
import FeatureArchiveTrackSearchInterface
import ArchiveDomain
import TrackSearchDomain
import MSDomain
import ComposableArchitecture

final class AddArchiveComponent: Component<AddArchiveDependency> {
	fileprivate var archiveRepository: ArchiveRepository {
		return dependency.archiveRepository
	}
	fileprivate var searchTracksUseCase: SearchTracksUseCase {
		return dependency.searchTracksUseCase
	}

	fileprivate var archiveTrackSearchBuilder: ArchiveTrackSearchBuildable {
		return dependency.archiveTrackSearchBuilder
	}
}

public final class AddArchiveBuilder: Builder<AddArchiveDependency>, AddArchiveBuildable {
	public override init(dependency: AddArchiveDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: AddArchiveListener, editTrack: ArchivedTrack? = nil) -> AddArchiveRouting {
		let component = AddArchiveComponent(dependency: dependency)

		final class DelegateProxy {
			weak var interactor: AddArchiveInteractor?
		}
		let proxy = DelegateProxy()

		let store = Store(initialState: AddArchiveFeature.State(editTrack: editTrack)) {
			AddArchiveFeature(
				archiveRepository: component.archiveRepository,
				searchTracksUseCase: component.searchTracksUseCase,

				onDelegate: { [weak proxy] action in
					guard let interactor = proxy?.interactor else { return }
					switch action {
					case .didCloseAddArchive:
						interactor.listener?.didCloseAddArchive()
					case .didTapSearchTrack:
						interactor.router?.routeToArchiveTrackSearch()
					}
				}
			)
		}

		let view = AddArchiveView(store: store)
		let viewController = AddArchiveViewController(rootView: view)
		viewController.view.backgroundColor = .clear

		let interactor = AddArchiveInteractor(presenter: viewController)
		interactor.listener = listener
		proxy.interactor = interactor

		interactor.onTrackSelected = { track in
			store.send(.trackSelected(track))
		}

		let router = AddArchiveRouter(
			interactor: interactor,
			viewController: viewController,
			archiveTrackSearchBuilder: component.archiveTrackSearchBuilder
		)
		interactor.router = router

		return router
	}
}
