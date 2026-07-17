import Foundation
import UIKit
import MicroRIBs
import MSDomain
import ArchiveDomain
import FeatureArchiveFolder
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface

@MainActor
final class ExampleAppComponent: ArchiveFolderDependency {
    let scenario: DemoScenario

    init(scenario: DemoScenario) {
        self.scenario = scenario
    }

    var archiveRepository: ArchiveRepository {
        MockArchiveRepository(scenario: scenario)
    }
    var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
        MockArchiveFolderDetailBuilder()
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    let scenario: DemoScenario
    
    init(scenario: DemoScenario = .success) {
        self.scenario = scenario
    }
    
    func fetchArchivedTracks() async throws -> [ArchivedTrack] {
        switch scenario {
        case .success:
            return [
                ArchivedTrack(id: UUID(), title: "Test Track 1", artist: "Test Artist 1", genre: "Pop", label: "", rating: 0),
                ArchivedTrack(id: UUID(), title: "Test Track 2", artist: "Test Artist 2", genre: "Rock", label: "", rating: 0)
            ]
        case .empty:
            return []
        case .error:
            throw NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "네트워크 에러 발생"])
        case .delayed:
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            return [
                ArchivedTrack(id: UUID(), title: "Delayed Track", artist: "Delayed Artist", genre: "Indie", label: "", rating: 0)
            ]
        }
    }
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockArchiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
    func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting {
        return MockArchiveFolderDetailRouter()
    }
}

@MainActor
final class MockArchiveFolderDetailRouter: ViewableRouter<Interactable, ViewControllable>, ArchiveFolderDetailRouting {
    init() {
        super.init(interactor: MockInteractable(), viewController: MockViewControllable())
    }
    func routeToFolderDetail(folderItem: FolderItem) {}
    func detachFolderDetail(popUI: Bool) {}
}

@MainActor
final class MockViewControllable: UIViewController, ViewControllable {
}

@MainActor
final class MockInteractable: Interactor {
}
