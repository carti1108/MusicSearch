import Foundation
import UIKit
import Combine
import MicroRIBs
import ArchiveDomain
import MSDomain
import FeatureArchiveFolderDetailInterface
import FeatureArchiveFolderDetail

public final class MockArchiveFolderDetailPresentable: ArchiveFolderDetailPresentable, @unchecked Sendable {
    public var listener: ArchiveFolderDetailPresentableListener?
    
    public var updateStateCallCount = 0
    public var lastState: ArchiveFolderDetailViewState?
    
    public init() {}
    
    public func update(state: ArchiveFolderDetailViewState) {
        updateStateCallCount += 1
        lastState = state
    }
    
    public var showLoginPromptCallCount = 0
    public func showLoginPrompt() {
        showLoginPromptCallCount += 1
    }
}

public final class MockArchiveFolderDetailListener: ArchiveFolderDetailListener, @unchecked Sendable {
    public var archiveFolderDetailDidTapCloseCallCount = 0
    public var didTapFolderCallCount = 0
    public var didTapTrackCallCount = 0
    public var didTapExportCallCount = 0
    public var didTapLoginCallCount = 0
    
    public init() {}
    
    public func archiveFolderDetailDidTapClose() {
        archiveFolderDetailDidTapCloseCallCount += 1
    }
    
    public func didTapClose() {
        archiveFolderDetailDidTapCloseCallCount += 1
    }
    
    public func didTapFolder(_ folder: FolderItem) {
        didTapFolderCallCount += 1
    }
    
    public func didTapTrack(_ track: ArchivedTrack) {
        didTapTrackCallCount += 1
    }
    
    public func didTapExport() {
        didTapExportCallCount += 1
    }
    
    public func didTapLogin() {
        didTapLoginCallCount += 1
    }
}

public final class MockArchiveFolderDetailRouting: ArchiveFolderDetailRouting, @unchecked Sendable {
    public var viewControllable: ViewControllable
    public var interactable: Interactable {
        get { fatalError() }
        set { fatalError() }
    }
    public var children: [Routing] = []
    
    public var routeToFolderDetailCallCount = 0
    public var lastRoutedFolderItem: FolderItem?
    
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
        lastRoutedFolderItem = folderItem
    }
    
    public func detachFolderDetail() {
        detachFolderDetailCallCount += 1
    }
}

public final class MockArchiveFolderDetailBuildable: ArchiveFolderDetailBuildable, @unchecked Sendable {
    public var buildCallCount = 0
    public var lastListener: ArchiveFolderDetailListener?
    public var lastFolderItem: FolderItem?
    public var buildResult: ArchiveFolderDetailRouting!
    
    public init() {}
    
    public func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting {
        buildCallCount += 1
        lastListener = listener
        lastFolderItem = folderItem
        return buildResult
    }
}

public final class MockManageSpotifyAuthUseCase: ManageSpotifyAuthUseCase, @unchecked Sendable {
    public var getAccessTokenResult: String?
    public var authorizeCallCount = 0
    public var disconnectCallCount = 0
    
    public init() {}
    
    public func getAccessToken() -> String? { return getAccessTokenResult }
    public func authorize() async throws { authorizeCallCount += 1 }
    public func disconnect() { disconnectCallCount += 1 }
}

public final class MockArchiveFolderDetailDependency: ArchiveFolderDetailDependency, @unchecked Sendable {
    public var archiveRepository: ArchiveRepository
    public var exportToSpotifyUseCase: ExportToSpotifyUseCase
    public var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase
    
    public init(archiveRepository: ArchiveRepository, exportToSpotifyUseCase: ExportToSpotifyUseCase, manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase) {
        self.archiveRepository = archiveRepository
        self.exportToSpotifyUseCase = exportToSpotifyUseCase
        self.manageSpotifyAuthUseCase = manageSpotifyAuthUseCase
    }
}

public final class MockArchiveFolderDetailViewControllable: ArchiveFolderDetailViewControllable, @unchecked Sendable {
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
