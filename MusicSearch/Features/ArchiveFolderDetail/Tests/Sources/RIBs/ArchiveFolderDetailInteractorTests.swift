import Foundation
import Testing
@testable import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailInterface
import FeatureArchiveFolderDetailTesting
import MSDomain
import ArchiveDomain
import ArchiveTesting

@MainActor
struct ArchiveFolderDetailInteractorTests {

    @Test("didBecomeActive 시 트랙을 불러와서 State를 업데이트하는가")
    func didBecomeActiveFetchesTracks() async {
        // Given
        let presenter = MockArchiveFolderDetailPresentable()
        let repository = MockArchiveRepository()
        let exportUseCase = MockExportToSpotifyUseCase()
        let folderItem = FolderItem(title: "Pop", subtitle: "2 곡", type: .genre(name: "Pop"))
        
        let track1 = ArchivedTrack(id: UUID(), title: "Track 1", artist: "Artist 1", genre: "Pop", releaseDate: Date(), listenDate: Date())
        let track2 = ArchivedTrack(id: UUID(), title: "Track 2", artist: "Artist 2", genre: "Pop", releaseDate: Date(), listenDate: Date())
        repository.fetchArchivedTracksResult = [track1, track2]
        
        let interactor = ArchiveFolderDetailInteractor(
            presenter: presenter,
            folderItem: folderItem,
            archiveRepository: repository,
            exportToSpotifyUseCase: exportUseCase
        )
        
        // When
        interactor.didBecomeActive()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(repository.fetchArchivedTracksCallCount == 1)
        #expect(presenter.updateStateCallCount > 0)
        #expect(presenter.lastState?.tracks?.count == 2)
    }

    @Test("didTapClose 시 listener의 archiveFolderDetailDidTapClose를 호출하는가")
    func didTapCloseNotifiesListener() {
        // Given
        let presenter = MockArchiveFolderDetailPresentable()
        let folderItem = FolderItem(title: "Test", subtitle: "0 곡", type: .custom)
        let listener = MockArchiveFolderDetailListener()
        let archiveRepository = MockArchiveRepository()
        let exportToSpotifyUseCase = MockExportToSpotifyUseCase()
        let manageSpotifyAuthUseCase = MockManageSpotifyAuthUseCase()
        let interactor = ArchiveFolderDetailInteractor(
            presenter: presenter,
            folderItem: folderItem,
            archiveRepository: archiveRepository,
            exportToSpotifyUseCase: exportToSpotifyUseCase,
            manageSpotifyAuthUseCase: manageSpotifyAuthUseCase
        )
        interactor.listener = listener
        
        // When
        interactor.didTapClose()
        
        // Then
        #expect(listener.archiveFolderDetailDidTapCloseCallCount == 1)
    }

    @Test("didTapFolder 시 router를 통해 자식 라우터로 이동하는가")
    func didTapFolderRoutesToDetail() {
        // Given
        let presenter = MockArchiveFolderDetailPresentable()
        let repository = MockArchiveRepository()
        let exportUseCase = MockExportToSpotifyUseCase()
        let folderItem = FolderItem(title: "Year 2026", subtitle: "10 곡", type: .releaseYear(year: "2026"))
        let childFolder = FolderItem(title: "06월", subtitle: "5 곡", type: .releaseMonth(year: "2026", month: "06"))
        
        let interactor = ArchiveFolderDetailInteractor(
            presenter: presenter,
            folderItem: folderItem,
            archiveRepository: repository,
            exportToSpotifyUseCase: exportUseCase
        )
        let router = MockArchiveFolderDetailRouting(interactor: interactor, viewController: MockArchiveFolderDetailViewControllable())
        interactor.router = router
        
        // When
        interactor.didTapFolder(childFolder)
        
        // Then
        #expect(router.routeToFolderDetailCallCount == 1)
        #expect(router.lastRoutedFolderItem?.title == "06월")
    }

    @Test("archiveFolderDetailDidTapClose 시 자식 라우터를 분리하는가")
    func archiveFolderDetailDidTapCloseDetachesChild() {
        // Given
        let presenter = MockArchiveFolderDetailPresentable()
        let repository = MockArchiveRepository()
        let exportUseCase = MockExportToSpotifyUseCase()
        let folderItem = FolderItem(title: "Year", subtitle: "", type: .releaseYear(year: "2026"))
        
        let interactor = ArchiveFolderDetailInteractor(
            presenter: presenter,
            folderItem: folderItem,
            archiveRepository: repository,
            exportToSpotifyUseCase: exportUseCase
        )
        let router = MockArchiveFolderDetailRouting(interactor: interactor, viewController: MockArchiveFolderDetailViewControllable())
        interactor.router = router
        
        // When
        interactor.archiveFolderDetailDidTapClose()
        
        // Then
        #expect(router.detachFolderDetailCallCount == 1)
    }
}
