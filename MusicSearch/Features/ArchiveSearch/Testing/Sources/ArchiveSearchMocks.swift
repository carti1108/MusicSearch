import Foundation
import UIKit
import Combine
import MicroRIBs
import ArchiveDomain
import FeatureArchiveSearchInterface
@testable import FeatureArchiveSearch

public final class MockArchiveSearchRouting: ArchiveSearchRouting, @unchecked Sendable {
    public var viewControllable: ViewControllable
    public var interactable: Interactable {
        get { fatalError() }
        set { fatalError() }
    }
    public var children: [Routing] = []
    
    public var lifecycle: AsyncStream<RouterLifecycle> {
        return AsyncStream { _ in }
    }
    
    public init(interactor: Interactable, viewController: ViewControllable) {
        self.viewControllable = viewController
    }
    
    public func load() {}
    public func attachChild(_ child: Routing) {}
    public func detachChild(_ child: Routing) {}
}

public final class MockArchiveSearchDependency: ArchiveSearchDependency, @unchecked Sendable {
    public var archiveRepository: ArchiveRepository
    
    public init(archiveRepository: ArchiveRepository) {
        self.archiveRepository = archiveRepository
    }
}

public final class MockArchiveSearchViewControllable: ArchiveSearchViewControllable, @unchecked Sendable {
    @MainActor public var uiViewController: UIViewController {
        return UIViewController()
    }
    
    public init() {}
}

public final class MockArchiveSearchInteractable: ArchiveSearchInteractable, @unchecked Sendable {
    public var router: ArchiveSearchRouting?
    public var listener: ArchiveSearchListener?
    public var isActive: Bool = true
    public var isActiveStream: MicroRIBs.Observable<Bool> {
        return AsyncStream { _ in }
    }
    
    public init() {}
    
    public func activate() {}
    public func deactivate() {}
    public func archiveSearchDidTapClose() {}
}
