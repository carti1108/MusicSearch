import MicroRIBs
import FeatureArchiveFolderInterface
import ArchiveDomain

@MainActor
public protocol ArchiveFolderDependency: Dependency {
    var archiveRepository: ArchiveRepository { get }
}

final class ArchiveFolderComponent: Component<ArchiveFolderDependency> {
}

public final class ArchiveFolderBuilder: Builder<ArchiveFolderDependency>, ArchiveFolderBuildable {

    public override init(dependency: ArchiveFolderDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveFolderListener) -> ArchiveFolderRouting {
        let component = ArchiveFolderComponent(dependency: dependency)
        let viewModel = ArchiveFolderViewModel()
        let viewController = ArchiveFolderViewController(viewModel: viewModel)
        let interactor = ArchiveFolderInteractor(presenter: viewController, archiveRepository: component.dependency.archiveRepository, viewModel: viewModel)
        interactor.listener = listener
        return ArchiveFolderRouter(interactor: interactor, viewController: viewController)
    }
}
