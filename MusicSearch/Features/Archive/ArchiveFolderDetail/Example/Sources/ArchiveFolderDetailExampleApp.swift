import SwiftUI
import ComposableArchitecture
import FeatureArchiveFolderDetail
import ArchiveDomain
import MSDomain
import ArchiveSharedTesting
import MSTesting

@main
struct ArchiveFolderDetailExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ArchiveFolderDetailView(
                store: Store(initialState: ArchiveFolderDetailFeature.State(folderItem: .stub())) {
                    ArchiveFolderDetailFeature()
                } withDependencies: {
                    $0.archiveRepository = MockArchiveRepository(tracks: [])
                    $0.exportPlaylistUseCase = MockExportPlaylistUseCase()
                    $0.getMusicAccessTokenUseCase = MockGetMusicAccessTokenUseCase()
                    $0.authorizeMusicUseCase = MockAuthorizeMusicUseCase()
                }
            )
        }
    }
}

extension ArchiveFolderItem {
    static func stub() -> ArchiveFolderItem {
        return ArchiveFolderItem(id: 1, name: "Test Folder", trackCount: 5)
    }
}

