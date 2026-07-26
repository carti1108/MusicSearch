import SwiftUI
import ComposableArchitecture
import FeatureArchiveFolder
import ArchiveDomain
import ArchiveSharedTesting

@main
struct ArchiveFolderExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ArchiveFolderView(
                store: Store(initialState: ArchiveFolderFeature.State()) {
                    ArchiveFolderFeature()
                } withDependencies: {
                    $0.archiveRepository = MockArchiveRepository(tracks: [])
                }
            )
        }
    }
}


