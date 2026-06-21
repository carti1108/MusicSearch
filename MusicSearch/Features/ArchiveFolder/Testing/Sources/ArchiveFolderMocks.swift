import Foundation
import UIKit
import Combine
import MicroRIBs
import ArchiveDomain
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
@testable import FeatureArchiveFolder

public final class MockArchiveFolderRouting: ArchiveFolderRouting, @unchecked Sendable {
    public var viewControllable: ViewControllable
    public var interactable: Interactable {
        get { fatalError() }
        set { fatalError() }
    }
    public var children: [Routing] = []
    
    public var routeToFolderDetailCallCount = 0
    public var detachFolderDetailCallCount = 0
    
    public var lifecycle: AsyncStream<RouterLifecycle> {
        return AsyncStream { _ in }
    }
    
    public init(interactor: Interactable, viewController: ViewControllable) {
        self.viewControllable = viewController
    }
    
    public func load() {}
    public func attachChild(_ child: Routing) {}
    public func detachChild(_ child: Routing) {}
    
    public func routeToFolderDetail(folderItem: FolderItem) {
        routeToFolderDetailCallCount += 1
    }
    
    public func detachFolderDetail() {
        detachFolderDetailCallCount += 1
    }
}

public final class MockArchiveFolderDependency: ArchiveFolderDependency, @unchecked Sendable {
    public var archiveRepository: ArchiveRepository
    public var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable
    
    public init(archiveRepository: ArchiveRepository, archiveFolderDetailBuilder: ArchiveFolderDetailBuildable) {
        self.archiveRepository = archiveRepository
        self.archiveFolderDetailBuilder = archiveFolderDetailBuilder
    }
}

public final class MockArchiveFolderViewControllable: ArchiveFolderViewControllable, @unchecked Sendable {
    @MainActor public var uiViewController: UIViewController {
        return UIViewController()
    }
    
    public var pushCallCount = 0
    public var popCallCount = 0
    
    public init() {}
    
    public func push(viewController: ViewControllable, animated: Bool) {
        pushCallCount += 1
    }
    
    public func pop(animated: Bool) {
        popCallCount += 1
    }
}

public final class MockArchiveFolderInteractable: ArchiveFolderInteractable, @unchecked Sendable {
    public var router: ArchiveFolderRouting?
    public var listener: ArchiveFolderListener?
    public var isActive: Bool = true
    public var isActiveStream: MicroRIBs.Observable<Bool> {
        return AsyncStream { _ in }
    }
    
    public init() {}
    
    public func activate() {}
    public func deactivate() {}
    public func archiveFolderDetailDidTapClose() {}
}

public final class MockArchiveFolderDetailBuildableForFolder: ArchiveFolderDetailBuildable, @unchecked Sendable {
    public var buildCallCount = 0
    public var buildResult: ArchiveFolderDetailRouting!
    
    public init() {}
    
    public func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting {
        buildCallCount += 1
        return buildResult
    }
}

public final class MockArchiveFolderDetailRoutingForFolder: ArchiveFolderDetailRouting, @unchecked Sendable {
    public var viewControllable: ViewControllable
    public var interactable: Interactable {
        get { fatalError() }
        set { fatalError() }
    }
    public var children: [Routing] = []
    
    public var lifecycle: AsyncStream<RouterLifecycle> {
        return AsyncStream { _ in }
    }
    
    public init(viewController: ViewControllable) {
        self.viewControllable = viewController
    }
    
    public func load() {}
    public func attachChild(_ child: Routing) {}
    public func detachChild(_ child: Routing) {}
    public func routeToFolderDetail(folderItem: FolderItem) {}
    public func detachFolderDetail() {}
}
