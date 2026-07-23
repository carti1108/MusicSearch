import Foundation
import MicroRIBs
import FeatureArchiveTrackSearchInterface
import TrackSearchDomain
import MSDomain
import ComposableArchitecture

@MainActor
public protocol ArchiveTrackSearchDependency: MicroRIBs.Dependency {
	var searchTracksUseCase: SearchTracksUseCase { get }
}

final class ArchiveTrackSearchComponent: Component<ArchiveTrackSearchDependency> {
	fileprivate var searchTracksUseCase: SearchTracksUseCase {
		return dependency.searchTracksUseCase
	}
}

public final class ArchiveTrackSearchBuilder: Builder<ArchiveTrackSearchDependency>, ArchiveTrackSearchBuildable {
	public override init(dependency: ArchiveTrackSearchDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: ArchiveTrackSearchListener) -> ArchiveTrackSearchRouting {
		let component = ArchiveTrackSearchComponent(dependency: dependency)

		final class DelegateProxy {
			weak var interactor: ArchiveTrackSearchInteractor?
		}
		let proxy = DelegateProxy()

		let store = Store(initialState: ArchiveTrackSearchFeature.State()) {
			ArchiveTrackSearchFeature(
				searchTracksUseCase: component.searchTracksUseCase,
				onDelegate: { [weak proxy] action in
					guard let interactor = proxy?.interactor else { return }
					switch action {
					case let .trackSelected(track):
						interactor.listener?.archiveTrackSearchDidSelectTrack(track)
					}
				}
			)
		}

		let view = ArchiveTrackSearchView(store: store)
		let viewController = ArchiveTrackSearchViewController(rootView: view)
		viewController.view.backgroundColor = .clear

		let interactor = ArchiveTrackSearchInteractor(presenter: viewController)
		interactor.listener = listener
		proxy.interactor = interactor

		let router = ArchiveTrackSearchRouter(
			interactor: interactor,
			viewController: viewController
		)
		interactor.router = router

		return router
	}
}
