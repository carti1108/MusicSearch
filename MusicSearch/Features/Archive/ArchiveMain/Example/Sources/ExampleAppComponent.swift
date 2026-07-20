//
//  ExampleAppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

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
    let scenario: DemoScenario

    init(scenario: DemoScenario) {
        self.scenario = scenario
    }

    var archiveRepository: ArchiveRepository {
        MockArchiveRepository(scenario: scenario)
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
    func routeToArchiveTrackSearch() {}
    func detachArchiveTrackSearch() {}
}

final class MockArchiveSearchRouter: ViewableRouter<Interactable, ViewControllable>, ArchiveSearchRouting {
    init() { super.init(interactor: MockInteractable(), viewController: MockViewControllable()) }
}

final class MockArchiveFolderRouter: ViewableRouter<Interactable, ViewControllable>, ArchiveFolderRouting {
    init() { super.init(interactor: MockInteractable(), viewController: MockViewControllable()) }
    func routeToFolderDetail(folderItem: FolderItem) {}
    func detachFolderDetail(popUI: Bool) {}
}

final class MockArchiveFolderDetailRouter: ViewableRouter<Interactable, ViewControllable>, ArchiveFolderDetailRouting {
    init() { super.init(interactor: MockInteractable(), viewController: MockViewControllable()) }
    func routeToFolderDetail(folderItem: FolderItem) {}
    func detachFolderDetail(popUI: Bool) {}
}

final class MockViewControllable: ViewControllable {
    var uiViewController: UIViewController { UIViewController() }
}

final class MockInteractable: Interactable {
    var isActive: Bool = true
    var isActiveStream: AsyncStream<Bool> {
        let (stream, continuation) = AsyncStream.makeStream(of: Bool.self)
        continuation.yield(true)
        continuation.finish()
        return stream
    }

    func activate() {}
    func deactivate() {}
}

