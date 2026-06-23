import Foundation
import UIKit
import Combine
import MicroRIBs
import MSDomain
import ArchiveDomain
import FeatureArchive
import FeatureArchiveInterface
import FeatureAddArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface

@MainActor
final class ExampleAppComponent: ArchiveDependency {
    var archiveRepository: ArchiveRepository {
        MockArchiveRepository()
    }
    
    var addArchiveBuilder: AddArchiveBuildable {
        MockAddArchiveBuilder()
    }
    
    var archiveSearchBuilder: ArchiveSearchBuildable {
        MockArchiveSearchBuilder()
    }
    
    var archiveFolderBuilder: ArchiveFolderBuildable {
        MockArchiveFolderBuilder()
    }
    
    var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
        MockArchiveFolderDetailBuilder()
    }
}

// MARK: - Mocks

final class MockArchiveRepository: ArchiveRepository {
    func fetchArchivedTracks() async throws -> [ArchivedTrack] {
        return [
            ArchivedTrack(id: UUID(), title: "Test Track", artist: "Test Artist", genre: "Pop", label: "", rating: 0)
        ]
    }
    
    func addArchivedTrack(_ track: ArchivedTrack) async throws { }
    
    func updateArchivedTrack(_ track: ArchivedTrack) async throws { }
    
    func deleteArchivedTrack(id: UUID) async throws { }
}

final class MockAddArchiveBuilder: AddArchiveBuildable {
    func build(withListener listener: AddArchiveListener, editTrack: ArchivedTrack?) -> AddArchiveRouting {
        return MockAddArchiveRouter()
    }
}

final class MockArchiveSearchBuilder: ArchiveSearchBuildable {
    func build(withListener listener: ArchiveSearchListener) -> ArchiveSearchRouting {
        return MockArchiveSearchRouter()
    }
}

final class MockArchiveFolderBuilder: ArchiveFolderBuildable {
    func build(withListener listener: ArchiveFolderListener) -> ArchiveFolderRouting {
        return MockArchiveFolderRouter()
    }
}

final class MockArchiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
    func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting {
        return MockArchiveFolderDetailRouter()
    }
}

final class MockAddArchiveRouter: ViewableRouter<Interactable, ViewControllable>, AddArchiveRouting {
    init() { super.init(interactor: MockInteractable(), viewController: MockViewControllable()) }
}

final class MockArchiveSearchRouter: ViewableRouter<Interactable, ViewControllable>, ArchiveSearchRouting {
    init() { super.init(interactor: MockInteractable(), viewController: MockViewControllable()) }
}

final class MockArchiveFolderRouter: ViewableRouter<Interactable, ViewControllable>, ArchiveFolderRouting {
    init() { super.init(interactor: MockInteractable(), viewController: MockViewControllable()) }
    func routeToFolderDetail(folderItem: FolderItem) {}
    func detachFolderDetail() {}
}

final class MockArchiveFolderDetailRouter: ViewableRouter<Interactable, ViewControllable>, ArchiveFolderDetailRouting {
    init() { super.init(interactor: MockInteractable(), viewController: MockViewControllable()) }
    func routeToFolderDetail(folderItem: FolderItem) {}
    func detachFolderDetail() {}
}

final class MockViewControllable: ViewControllable {
    var uiViewController: UIViewController { UIViewController() }
}

final class MockInteractable: Interactable {
    var isActive: Bool = true
    var isActiveStream: AsyncStream<Bool> {
        AsyncStream { continuation in
            continuation.yield(true)
        }
    }
    func activate() {}
    func deactivate() {}
}

