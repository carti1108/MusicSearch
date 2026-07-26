import SwiftUI
import ComposableArchitecture
import FeatureArchiveSearch
import ArchiveDomain
import ArchiveSharedTesting

@main
struct ArchiveSearchExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ArchiveSearchView(
                store: Store(initialState: ArchiveSearchFeature.State()) {
                    ArchiveSearchFeature()
                } withDependencies: {
                    $0.archiveRepository = MockArchiveRepository(tracks: [])
                    $0.continuousClock = ImmediateClock()
                }
            )
        }
    }
}
