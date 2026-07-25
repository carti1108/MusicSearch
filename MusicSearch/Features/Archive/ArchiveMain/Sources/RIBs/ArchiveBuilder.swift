import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import FeatureArchiveInterface
import ArchiveDomain
import MSDomain
import FeatureArchiveSearch
import FeatureArchiveFolder
import FeatureArchiveFolderDetail
import FeatureAddArchive
import FeatureArchiveTrackSearch

final class ArchiveComponent: Component<ArchiveDependency> {
}

public final class ArchiveBuilder: Builder<ArchiveDependency>, ArchiveBuildable {

    public override init(dependency: ArchiveDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveListener) -> ArchiveRouting {
        let component = ArchiveComponent(dependency: dependency)

        let interactor = ArchiveInteractor()
        interactor.listener = listener

        let store = withDependencies {
            $0.archiveRepository = component.dependency.archiveRepository
            $0.exportPlaylistUseCase = component.dependency.exportPlaylistUseCase
            $0.getMusicAccessTokenUseCase = component.dependency.getMusicAccessTokenUseCase
            $0.authorizeMusicUseCase = component.dependency.authorizeMusicUseCase
            $0.searchTracksUseCase = component.dependency.searchTracksUseCase
        } operation: {
            Store(
                initialState: ArchiveState(),
                reducer: { ArchiveFeature() }
            )
        }

        let view = ArchiveView(
            store: store
        )

        let viewController = ArchiveHostingController(rootView: view)
        viewController.view.backgroundColor = .clear

        let router = ArchiveRouter(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = router

        return router
    }
}
