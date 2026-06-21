import MicroRIBs
import ArchiveDomain
import MSDomain
import FeatureArchiveFolderDetailInterface

public final class ArchiveFolderDetailComponent: Component<ArchiveFolderDetailDependency> {
    fileprivate var archiveRepository: ArchiveRepository {
        return dependency.archiveRepository
    }
    fileprivate var exportToSpotifyUseCase: ExportToSpotifyUseCase {
        return dependency.exportToSpotifyUseCase
    }
    fileprivate var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
        return dependency.manageSpotifyAuthUseCase
    }
}

public final class ArchiveFolderDetailBuilder: Builder<ArchiveFolderDetailDependency>, ArchiveFolderDetailBuildable {
    public override init(dependency: ArchiveFolderDetailDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting {
        let component = ArchiveFolderDetailComponent(dependency: dependency)
        let viewController = ArchiveFolderDetailViewController()
        let interactor = ArchiveFolderDetailInteractor(
            presenter: viewController, 
            folderItem: folderItem, 
            archiveRepository: component.archiveRepository, 
            exportToSpotifyUseCase: component.exportToSpotifyUseCase,
            manageSpotifyAuthUseCase: component.manageSpotifyAuthUseCase
        )
        interactor.listener = listener
        return ArchiveFolderDetailRouter(interactor: interactor, viewController: viewController, detailBuilder: self)
    }
}
