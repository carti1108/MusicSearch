import Foundation
import MicroRIBs
import FeatureArchiveFolderInterface
import ArchiveDomain
import FeatureArchiveFolderDetailInterface
import ComposableArchitecture

@MainActor
public protocol ArchiveFolderDependency: MicroRIBs.Dependency {
    var archiveRepository: ArchiveRepository { get }
    var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable { get }
}

final class ArchiveFolderComponent: Component<ArchiveFolderDependency> {
}

public final class ArchiveFolderBuilder: Builder<ArchiveFolderDependency>, ArchiveFolderBuildable {

    public override init(dependency: ArchiveFolderDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveFolderListener) -> ArchiveFolderRouting {
        let component = ArchiveFolderComponent(dependency: dependency)

        final class DelegateProxy {
            weak var interactor: ArchiveFolderInteractor?
        }
        let proxy = DelegateProxy()

        let store = Store(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature(
                archiveRepository: component.dependency.archiveRepository,
                onDelegate: { @MainActor @Sendable [weak proxy] action in
                    guard let interactor = proxy?.interactor else { return }
                    switch action {
                    case .didTapClose:
                        interactor.listener?.archiveFolderDidTapClose()
                    case let .didTapFolder(folderItem):
                        interactor.router?.routeToFolderDetail(folderItem: folderItem)
                    }
                }
            )
        }

        let view = ArchiveFolderView(store: store)
        let viewController = ArchiveFolderViewController(
            rootView: view
        )

        let interactor = ArchiveFolderInteractor(presenter: viewController)
        interactor.listener = listener
        proxy.interactor = interactor

        let router = ArchiveFolderRouter(
            interactor: interactor,
            viewController: viewController,
            detailBuilder: component.dependency.archiveFolderDetailBuilder
        )
        interactor.router = router

        return router
    }
}
