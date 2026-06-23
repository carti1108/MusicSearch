import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import ArchiveDomain
import MSDomain
import FeatureArchiveFolderDetailInterface



public final class ArchiveFolderDetailComponent: Component<ArchiveFolderDetailDependency> {
    fileprivate var archiveRepository: ArchiveRepository {
        return dependency.archiveRepository
    }
    fileprivate var exportToSpotifyUseCase: ExportToSpotifyUseCase {
        return dependency.exportToSpotifyUseCase
    }
    fileprivate var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
        return dependency.manageSpotifyAuthUseCase
    }
}

public protocol ArchiveFolderDetailInteractable: Interactable, ArchiveFolderDetailListener {
    var router: ArchiveFolderDetailRouting? { get set }
    var listener: ArchiveFolderDetailListener? { get set }
}

public final class ArchiveFolderDetailWrapperInteractor: Interactor, ArchiveFolderDetailInteractable, ArchiveFolderDetailListener {
    public weak var router: ArchiveFolderDetailRouting?
    public weak var listener: ArchiveFolderDetailListener?
    public var onShowLoginPrompt: (() -> Void)?
    public var onExportButtonTapped: (() -> Void)?
    
    public func archiveFolderDetailDidTapClose() {
        router?.detachFolderDetail(popUI: false)
    }
    
    public func archiveFolderDetailDidTapFolder(_ folderItem: FolderItem) {
    }
    
    public func archiveFolderDetailDidTapTrack(_ track: ArchivedTrack) {
        listener?.archiveFolderDetailDidTapTrack(track)
    }
}

public final class ArchiveFolderDetailHostingController: UIHostingController<ArchiveFolderDetailView>, ViewControllable {
    public var uiviewController: UIViewController { self }
    private weak var interactor: ArchiveFolderDetailWrapperInteractor?
    private let store: StoreOf<ArchiveFolderDetailFeature>
    
    init(rootView: ArchiveFolderDetailView, store: StoreOf<ArchiveFolderDetailFeature>, interactor: ArchiveFolderDetailWrapperInteractor) {
        self.store = store
        self.interactor = interactor
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
        
        self.interactor?.onShowLoginPrompt = { [weak self] in
            self?.showLoginPrompt()
        }
        self.interactor?.onExportButtonTapped = { [weak self] in
            self?.store.send(.exportButtonTapped)
        }
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            interactor?.listener?.archiveFolderDetailDidTapClose()
        }
    }
    
    private func setupNavigation() {
        self.title = store.title
        
        var showExportButton = false
        switch store.folderItem.type {
        case .releaseYear, .listenYear, .releaseMonth, .listenMonth:
            showExportButton = false
        default:
            showExportButton = true
        }
        
        if showExportButton {
            let exportButton = UIBarButtonItem(
                title: "플레이리스트 내보내기",
                style: .plain,
                target: self,
                action: #selector(exportButtonTapped)
            )
            self.navigationItem.rightBarButtonItem = exportButton
        }
    }
    
    @objc private func exportButtonTapped() {
        store.send(.exportButtonTapped)
    }
    
    public func showLoginPrompt() {
        let alert = UIAlertController(
            title: "연동 필요",
            message: "플레이리스트를 내보내려면 스포티파이 연동이 필요합니다. 지금 연동하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "연동하기", style: .default) { [weak self] _ in
            self?.store.send(.loginPromptTapped)
        })
        self.present(alert, animated: true)
    }
}

public final class ArchiveFolderDetailWrapperRouter: ViewableRouter<ArchiveFolderDetailInteractable, ViewControllable>, ArchiveFolderDetailRouting {
    private let detailBuilder: ArchiveFolderDetailBuildable
    private var detailRouter: ArchiveFolderDetailRouting?
    
    init(interactor: ArchiveFolderDetailInteractable, viewController: ViewControllable, detailBuilder: ArchiveFolderDetailBuildable) {
        self.detailBuilder = detailBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    public func routeToFolderDetail(folderItem: FolderItem) {
        guard detailRouter == nil else { return }
        let router = detailBuilder.build(withListener: interactor, folderItem: folderItem)
        self.detailRouter = router
        attachChild(router)
        viewController.uiviewController.navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
    }
    
    public func detachFolderDetail(popUI: Bool) {
        guard let router = detailRouter else { return }
        if popUI {
            viewController.uiviewController.navigationController?.popViewController(animated: true)
        }
        detachChild(router)
        self.detailRouter = nil
    }
}

public final class ArchiveFolderDetailBuilder: Builder<ArchiveFolderDetailDependency>, ArchiveFolderDetailBuildable {
    public override init(dependency: ArchiveFolderDetailDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting {
        let component = ArchiveFolderDetailComponent(dependency: dependency)
        
        let interactor = ArchiveFolderDetailWrapperInteractor()
        interactor.listener = listener
        
        let store = Store(initialState: ArchiveFolderDetailFeature.State(folderItem: folderItem)) {
            ArchiveFolderDetailFeature(
                archiveRepository: component.archiveRepository,
                exportToSpotifyUseCase: component.exportToSpotifyUseCase,
                manageSpotifyAuthUseCase: component.manageSpotifyAuthUseCase,
                onDelegate: { [weak interactor] action in
                    switch action {
                    case .didTapClose:
                        interactor?.listener?.archiveFolderDetailDidTapClose()
                    case let .didTapFolder(folderItem):
                        interactor?.router?.routeToFolderDetail(folderItem: folderItem)
                    case let .didTapTrack(track):
                        interactor?.listener?.archiveFolderDetailDidTapTrack(track)
                    case .didTapLogin:
                        Task {
                            do {
                                try await component.manageSpotifyAuthUseCase.authorize()
                                await MainActor.run {
                                    interactor?.onExportButtonTapped?()
                                }
                            } catch {
                                print("Failed to authorize Spotify: \(error)")
                            }
                        }
                    case .showLoginPrompt:
                        interactor?.onShowLoginPrompt?()
                    }
                }
            )
        }
        
        let view = ArchiveFolderDetailView(store: store)
        let viewController = ArchiveFolderDetailHostingController(
            rootView: view,
            store: store,
            interactor: interactor
        )
        
        let router = ArchiveFolderDetailWrapperRouter(
            interactor: interactor,
            viewController: viewController,
            detailBuilder: self
        )
        interactor.router = router
        
        return router
    }
}
