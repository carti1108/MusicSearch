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

        let store = Store(
            initialState: ArchiveState(),
            reducer: {
                ArchiveFeature(
                    archiveRepository: component.dependency.archiveRepository,
                    search: ArchiveSearchFeature(archiveRepository: component.dependency.archiveRepository),
                    folder: ArchiveFolderFeature(archiveRepository: component.dependency.archiveRepository),
                    folderDetail: ArchiveFolderDetailFeature(
                        archiveRepository: component.dependency.archiveRepository,
                        exportPlaylistUseCase: component.dependency.exportPlaylistUseCase,
                        getMusicAccessTokenUseCase: component.dependency.getMusicAccessTokenUseCase,
                        authorizeMusicUseCase: component.dependency.authorizeMusicUseCase
                    ),
                    addArchive: AddArchiveFeature(
                        archiveRepository: component.dependency.archiveRepository,
                        searchTracksUseCase: component.dependency.searchTracksUseCase,
                        trackSearch: ArchiveTrackSearchFeature(searchTracksUseCase: component.dependency.searchTracksUseCase)
                    )
                )
            }
        )

        let view = ArchiveView(
            store: store,
            destinationViews: ArchiveDestinationViews(
                search: { store in AnyView(ArchiveSearchView(store: store)) },
                folder: { store in AnyView(ArchiveFolderView(store: store)) },
                addArchive: { store in AnyView(AddArchiveView(store: store, trackSearchView: { store in ArchiveTrackSearchView(store: store) })) },
                editArchive: { store in AnyView(AddArchiveView(store: store, trackSearchView: { store in ArchiveTrackSearchView(store: store) })) },
                folderDetail: { store in AnyView(ArchiveFolderDetailView(store: store)) }
            )
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
