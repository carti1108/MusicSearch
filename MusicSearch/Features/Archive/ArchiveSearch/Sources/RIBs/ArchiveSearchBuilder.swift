import Foundation
import MicroRIBs
import FeatureArchiveSearchInterface
import ArchiveDomain
import ComposableArchitecture

@MainActor
public protocol ArchiveSearchDependency: MicroRIBs.Dependency {
    var archiveRepository: ArchiveRepository { get }
}

final class ArchiveSearchComponent: Component<ArchiveSearchDependency> {
}

public final class ArchiveSearchBuilder: Builder<ArchiveSearchDependency>, ArchiveSearchBuildable {

    public override init(dependency: ArchiveSearchDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveSearchListener) -> ArchiveSearchRouting {
        let component = ArchiveSearchComponent(dependency: dependency)

        let store = Store(initialState: ArchiveSearchFeature.State()) {
            ArchiveSearchFeature(archiveRepository: component.dependency.archiveRepository)
        }

        let view = ArchiveSearchView(store: store)
        let viewController = ArchiveSearchViewController(rootView: view)

        let interactor = ArchiveSearchInteractor(presenter: viewController)
        interactor.listener = listener

        let router = ArchiveSearchRouter(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = router

        return router
    }
}
