import MicroRIBs
import FeatureArchiveSearchInterface
import ArchiveDomain
import FeatureArchiveSearchInterface

@MainActor
public protocol ArchiveSearchDependency: Dependency {
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
        let viewModel = ArchiveSearchViewModel()
        let viewController = ArchiveSearchViewController(viewModel: viewModel)
        let interactor = ArchiveSearchInteractor(presenter: viewController, archiveRepository: component.dependency.archiveRepository, viewModel: viewModel)
        interactor.listener = listener
        return ArchiveSearchRouter(interactor: interactor, viewController: viewController)
    }
}
