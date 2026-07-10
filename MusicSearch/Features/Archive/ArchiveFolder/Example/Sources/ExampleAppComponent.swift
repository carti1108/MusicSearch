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
        MockArchiveRepository()
    }
    var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
        MockArchiveFolderDetailBuilder()
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] { return [] }
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
