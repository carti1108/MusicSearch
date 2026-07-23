import MicroRIBs
import FeatureArchiveInterface
import FeatureAddArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import ArchiveDomain
import ComposableArchitecture

public final class ArchiveComponent: Component<ArchiveDependency> {
    fileprivate var archiveRepository: ArchiveRepository {
        dependency.archiveRepository
    }
    fileprivate var addArchiveBuilder: AddArchiveBuildable {
        dependency.addArchiveBuilder
    }
    fileprivate var archiveSearchBuilder: ArchiveSearchBuildable {
        dependency.archiveSearchBuilder
    }
    fileprivate var archiveFolderBuilder: ArchiveFolderBuildable {
        dependency.archiveFolderBuilder
    }
}

public final class ArchiveBuilder: Builder<ArchiveDependency>, ArchiveBuildable {
    public override init(dependency: ArchiveDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveListener) -> ArchiveRouting {
        let component = ArchiveComponent(dependency: dependency)

        final class DelegateProxy {
            weak var interactor: ArchiveInteractor?
        }
        let proxy = DelegateProxy()

        let store = Store(initialState: ArchiveFeature.State()) {
            ArchiveFeature(
                archiveRepository: component.archiveRepository,
                onDelegate: { @MainActor @Sendable [weak proxy] action in
                    guard let interactor = proxy?.interactor else { return }
                    switch action {
                    case .routeToAddArchive:
                        interactor.router?.routeToAddArchive()
                    case let .routeToEditArchive(track):
                        interactor.router?.routeToEditArchive(track: track)
                    case .routeToSearch:
                        interactor.router?.routeToSearch()
                    case .routeToFolder:
                        interactor.router?.routeToFolder()
                    }
                }
            )
        }

        let view = ArchiveView(store: store)
        let viewController = ArchiveViewController(
            rootView: view,
            store: store
        )
        
        let interactor = ArchiveInteractor(presenter: viewController)
        interactor.listener = listener
        proxy.interactor = interactor

        interactor.onRefresh = { [weak store] in
            store?.send(.onAppear)
        }

        let router = ArchiveRouter(
            interactor: interactor,
            viewController: viewController,
            addArchiveBuilder: component.addArchiveBuilder,
            archiveSearchBuilder: component.archiveSearchBuilder,
            archiveFolderBuilder: component.archiveFolderBuilder
        )
        interactor.router = router

        return router
    }
}
