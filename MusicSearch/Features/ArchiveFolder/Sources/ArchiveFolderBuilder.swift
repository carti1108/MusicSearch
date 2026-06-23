import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import FeatureArchiveFolderInterface
import ArchiveDomain
import FeatureArchiveFolderDetailInterface

@MainActor
public protocol ArchiveFolderDependency: MicroRIBs.Dependency {
    var archiveRepository: ArchiveRepository { get }
    var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable { get }
}

final class ArchiveFolderComponent: Component<ArchiveFolderDependency> {
}

public protocol ArchiveFolderInteractable: Interactable, ArchiveFolderDetailListener {
    var router: ArchiveFolderRouting? { get set }
    var listener: ArchiveFolderListener? { get set }
}

public final class ArchiveFolderWrapperInteractor: Interactor, ArchiveFolderInteractable {
    public weak var router: ArchiveFolderRouting?
    public weak var listener: ArchiveFolderListener?
    
    public func archiveFolderDetailDidTapClose() {
        router?.detachFolderDetail(popUI: false)
    }
    
    public func archiveFolderDetailDidTapFolder(_ folderItem: FolderItem) {
    }
    
    public func archiveFolderDetailDidTapTrack(_ track: ArchivedTrack) {
        listener?.archiveFolderDidTapTrack(track)
    }
}

public final class ArchiveFolderHostingController: UIHostingController<ArchiveFolderView>, ViewControllable {
    public var uiviewController: UIViewController { self }
    private weak var interactor: ArchiveFolderWrapperInteractor?
    
    init(rootView: ArchiveFolderView, interactor: ArchiveFolderWrapperInteractor) {
        self.interactor = interactor
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "보관함 폴더"
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            interactor?.listener?.archiveFolderDidTapClose()
        }
    }
    

    
}

public final class ArchiveFolderWrapperRouter: ViewableRouter<ArchiveFolderInteractable, ViewControllable>, ArchiveFolderRouting {
    private let detailBuilder: ArchiveFolderDetailBuildable
    private var detailRouter: ArchiveFolderDetailRouting?
    
    init(interactor: ArchiveFolderInteractable, viewController: ViewControllable, detailBuilder: ArchiveFolderDetailBuildable) {
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

public final class ArchiveFolderBuilder: Builder<ArchiveFolderDependency>, ArchiveFolderBuildable {

    public override init(dependency: ArchiveFolderDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveFolderListener) -> ArchiveFolderRouting {
        let component = ArchiveFolderComponent(dependency: dependency)
        
        let interactor = ArchiveFolderWrapperInteractor()
        interactor.listener = listener
        
        let store = Store(initialState: ArchiveFolderFeature.State()) {
            ArchiveFolderFeature(
                archiveRepository: component.dependency.archiveRepository,
                onDelegate: { [weak interactor] action in
                    switch action {
                    case .didTapClose:
                        interactor?.listener?.archiveFolderDidTapClose()
                    case let .didTapFolder(folderItem):
                        interactor?.router?.routeToFolderDetail(folderItem: folderItem)
                    }
                }
            )
        }
        
        let view = ArchiveFolderView(store: store)
        let viewController = ArchiveFolderHostingController(
            rootView: view,
            interactor: interactor
        )
        
        let router = ArchiveFolderWrapperRouter(
            interactor: interactor,
            viewController: viewController,
            detailBuilder: component.dependency.archiveFolderDetailBuilder
        )
        interactor.router = router
        
        return router
    }
}
