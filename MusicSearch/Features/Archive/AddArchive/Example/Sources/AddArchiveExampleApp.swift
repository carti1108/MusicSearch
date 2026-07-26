import SwiftUI
import ComposableArchitecture
import FeatureAddArchive
import ArchiveDomain
import MSDomain
import TrackSearchDomain
import ArchiveSharedTesting
import FeatureTrackSearchTesting

@main
struct AddArchiveExampleApp: App {
    var body: some Scene {
        WindowGroup {
            AddArchiveView(
                store: Store(initialState: AddArchiveFeature.State()) {
                    AddArchiveFeature()
                } withDependencies: {
                    $0.archiveRepository = MockArchiveRepository(tracks: [])
                    $0.searchTracksUseCase = MockSearchTracksUseCase()
                    $0.imageClient = ImageClient(fetch: { _ in Data() })
                }
            )
        }
    }
}
