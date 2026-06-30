import XCTest
import ComposableArchitecture
import ArchiveDomain
@testable import FeatureArchiveFolder

@MainActor
final class ArchiveFolderFeatureTests: XCTestCase {
    func testOnAppear() async {
        let expectedFolders = [
            FolderItem(id: "1", name: "Pop", createdAt: Date(), trackIDs: ["t1"]),
            FolderItem(id: "2", name: "Rock", createdAt: Date(), trackIDs: ["t2"])
        ]

        let store = TestStore(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature(archiveRepository: MockArchiveRepository(folders: expectedFolders)) { _ in }
        }

        await store.send(.onAppear)
        await store.receive(\.loadDataResponse) {
            $0.folders = expectedFolders
        }
    }

    func testAddFolder() async {
        let store = TestStore(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature(archiveRepository: MockArchiveRepository(folders: [])) { _ in }
        }

        await store.send(.addFolderButtonTapped) {
            $0.isAddFolderAlertPresented = true
        }

        await store.send(.binding(.set(\.newFolderName, "My New Folder"))) {
            $0.newFolderName = "My New Folder"
        }

        await store.send(.addFolderConfirmTapped) {
            $0.isAddFolderAlertPresented = false
        }

        await store.receive(\.onAppear)
        await store.receive(\.loadDataResponse)

        await store.send(.binding(.set(\.newFolderName, ""))) {
            $0.newFolderName = ""
        }
    }

    func testFolderTapped() async {
        let folder = FolderItem(id: "1", name: "Pop", createdAt: Date(), trackIDs: ["t1"])

        var delegatedActions: [ArchiveFolderFeature.DelegateAction] = []
        let store = TestStore(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature(archiveRepository: MockArchiveRepository(folders: [folder])) { action in
                delegatedActions.append(action)
            }
        }

        await store.send(.folderTapped(folder))

        XCTAssertEqual(delegatedActions.count, 1)
    }
}

final class MockArchiveRepository: ArchiveRepository {
    var folders: [FolderItem]
    init(folders: [FolderItem]) { self.folders = folders }

    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return [] }
    func saveArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
    func fetchFolders() async throws -> [FolderItem] { return folders }
    func saveFolder(_ folder: FolderItem) async throws { }
    func deleteFolder(id: String) async throws { }
    func addTrackToFolder(trackID: String, folderID: String) async throws { }
    func removeTrackFromFolder(trackID: String, folderID: String) async throws { }
}
