import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain
import FeatureArchiveFolderDetailInterface
import ComposableArchitecture

public final class ArchiveFolderDetailComponent: Component<ArchiveFolderDetailDependency> {
    fileprivate var archiveRepository: ArchiveRepository {
        return dependency.archiveRepository
    }
    fileprivate var exportPlaylistUseCase: ExportPlaylistUseCase {
        return dependency.exportPlaylistUseCase
    }
    fileprivate var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
        return dependency.getMusicAccessTokenUseCase
    }
    fileprivate var authorizeMusicUseCase: AuthorizeMusicUseCase {
        return dependency.authorizeMusicUseCase
    }
}

public final class ArchiveFolderDetailBuilder: Builder<ArchiveFolderDetailDependency>, ArchiveFolderDetailBuildable {
    public override init(dependency: ArchiveFolderDetailDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting {
        let component = ArchiveFolderDetailComponent(dependency: dependency)

        final class DelegateProxy {
            weak var interactor: ArchiveFolderDetailInteractor?
        }
        let proxy = DelegateProxy()

        let store = Store(initialState: ArchiveFolderDetailFeature.State(folderItem: folderItem)) {
            ArchiveFolderDetailFeature(
                archiveRepository: component.archiveRepository,
                exportPlaylistUseCase: component.exportPlaylistUseCase,
                getMusicAccessTokenUseCase: component.getMusicAccessTokenUseCase,
                authorizeMusicUseCase: component.authorizeMusicUseCase,
                onDelegate: { [weak proxy] action in
                    guard let interactor = proxy?.interactor else { return }
                    switch action {
                    case .didTapClose:
                        interactor.listener?.archiveFolderDetailDidTapClose()
                    case let .didTapFolder(folderItem):
                        interactor.listener?.archiveFolderDetailDidTapFolder(folderItem)
                    case let .didTapTrack(track):
                        interactor.listener?.archiveFolderDetailDidTapTrack(track)
                    case .showLoginPrompt:
                        interactor.showLoginPrompt()
                    }
                }
            )
        }

        let view = ArchiveFolderDetailView(store: store)
        let viewController = ArchiveFolderDetailViewController(
            rootView: view,
            store: store
        )

        let interactor = ArchiveFolderDetailInteractor(presenter: viewController)
        interactor.listener = listener
        proxy.interactor = interactor

        let router = ArchiveFolderDetailRouter(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = router

        return router
    }
}
