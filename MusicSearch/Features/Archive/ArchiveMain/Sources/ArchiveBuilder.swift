import MicroRIBs
import FeatureArchiveInterface
import FeatureAddArchiveInterface
import ArchiveDomain
import SwiftUI
import UIKit
import ComposableArchitecture
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface

public final class ArchiveComponent: Component<ArchiveDependency> {
    fileprivate var archiveRepository: ArchiveRepository {
        dependency.archiveRepository
    }
    fileprivate var addArchiveBuilder: AddArchiveBuildable {
        dependency.addArchiveBuilder
    }
    fileprivate var archiveSearchBuilder: ArchiveSearchBuildable {
        dependency.archiveSearchBuilder
    }
    fileprivate var archiveFolderBuilder: ArchiveFolderBuildable {
        dependency.archiveFolderBuilder
    }
}

public protocol ArchiveInteractable: Interactable, AddArchiveListener, ArchiveSearchListener, ArchiveFolderListener {
    var router: ArchiveRouting? { get set }
    var listener: ArchiveListener? { get set }
}

public final class ArchiveWrapperInteractor: Interactor, ArchiveInteractable {
    public weak var router: ArchiveRouting?
    public weak var listener: ArchiveListener?
    public var onRefresh: (() -> Void)?

    public func didCloseAddArchive() {
        router?.detachAddArchive()
        onRefresh?()
    }

    public func archiveSearchDidTapClose() {
        router?.detachSearch()
        onRefresh?()
    }

    public func archiveFolderDidTapClose() {
        router?.detachFolder()
        onRefresh?()
    }

    public func archiveFolderDidTapTrack(_ track: ArchivedTrack) {
        router?.routeToEditArchive(track: track)
    }
}

public final class ArchiveHostingController: UIHostingController<ArchiveView>, ViewControllable, ArchiveViewControllable {
    public var uiviewController: UIViewController { self }
    private weak var interactor: ArchiveWrapperInteractor?
    private let store: StoreOf<ArchiveFeature>

    init(rootView: ArchiveView, store: StoreOf<ArchiveFeature>, interactor: ArchiveWrapperInteractor) {
        self.store = store
        self.interactor = interactor
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "나의 보관함"
        self.tabBarItem.title = "Archive"
        self.tabBarItem.image = UIImage(systemName: "archivebox")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.send(.onAppear)
    }

    public func push(viewController: ViewControllable, animated: Bool) {
        self.navigationController?.pushViewController(viewController.uiviewController, animated: animated)
    }

    public func pop(animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
    }
}

public protocol ArchiveViewControllable: ViewControllable {
    func push(viewController: ViewControllable, animated: Bool)
    func pop(animated: Bool)
}

public final class ArchiveWrapperRouter: ViewableRouter<ArchiveInteractable, ArchiveViewControllable>, ArchiveRouting {

    private let addArchiveBuilder: AddArchiveBuildable
    private var addArchiveRouting: ViewableRouting?

    private let archiveSearchBuilder: ArchiveSearchBuildable
    private var archiveSearchRouting: ViewableRouting?

    private let archiveFolderBuilder: ArchiveFolderBuildable
    private var archiveFolderRouting: ViewableRouting?

    public init(
        interactor: ArchiveInteractable,
        viewController: ArchiveViewControllable,
        addArchiveBuilder: AddArchiveBuildable,
        archiveSearchBuilder: ArchiveSearchBuildable,
        archiveFolderBuilder: ArchiveFolderBuildable
    ) {
        self.addArchiveBuilder = addArchiveBuilder
        self.archiveSearchBuilder = archiveSearchBuilder
        self.archiveFolderBuilder = archiveFolderBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    public func routeToAddArchive() {
        guard addArchiveRouting == nil else { return }
        let routing = addArchiveBuilder.build(withListener: interactor, editTrack: nil)
        self.addArchiveRouting = routing
        attachChild(routing)
        viewController.present(routing.viewControllable, animated: true, completion: nil)
    }

    public func routeToEditArchive(track: ArchivedTrack) {
        guard addArchiveRouting == nil else { return }
        let routing = addArchiveBuilder.build(withListener: interactor, editTrack: track)
        self.addArchiveRouting = routing
        attachChild(routing)
        viewController.present(routing.viewControllable, animated: true, completion: nil)
    }

    public func detachAddArchive() {
        guard let routing = addArchiveRouting else { return }
        viewController.dismiss(animated: true, completion: nil)
        detachChild(routing)
        self.addArchiveRouting = nil
    }

    public func routeToSearch() {
        guard archiveSearchRouting == nil else { return }
        let routing = archiveSearchBuilder.build(withListener: interactor)
        self.archiveSearchRouting = routing
        attachChild(routing)
        viewController.push(viewController: routing.viewControllable, animated: true)
    }

    public func detachSearch() {
        guard let routing = archiveSearchRouting else { return }
        viewController.pop(animated: true)
        detachChild(routing)
        self.archiveSearchRouting = nil
    }

    public func routeToFolder() {
        guard archiveFolderRouting == nil else { return }
        let routing = archiveFolderBuilder.build(withListener: interactor)
        self.archiveFolderRouting = routing
        attachChild(routing)
        viewController.push(viewController: routing.viewControllable, animated: true)
    }

    public func detachFolder() {
        guard let routing = archiveFolderRouting else { return }
        viewController.pop(animated: true)
        detachChild(routing)
        self.archiveFolderRouting = nil
    }
}

public final class ArchiveBuilder: Builder<ArchiveDependency>, ArchiveBuildable {
    public override init(dependency: ArchiveDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ArchiveListener) -> ArchiveRouting {
        let component = ArchiveComponent(dependency: dependency)

        let interactor = ArchiveWrapperInteractor()
        interactor.listener = listener

        let store = Store(initialState: ArchiveFeature.State()) {
            ArchiveFeature(
                archiveRepository: component.archiveRepository,
                onDelegate: { [weak interactor] action in
                    switch action {
                    case .routeToAddArchive:
                        interactor?.router?.routeToAddArchive()
                    case let .routeToEditArchive(track):
                        interactor?.router?.routeToEditArchive(track: track)
                    case .routeToSearch:
                        interactor?.router?.routeToSearch()
                    case .routeToFolder:
                        interactor?.router?.routeToFolder()
                    }
                }
            )
        }

        interactor.onRefresh = { [weak store] in
            store?.send(.onAppear)
        }

        let view = ArchiveView(store: store)
        let viewController = ArchiveHostingController(
            rootView: view,
            store: store,
            interactor: interactor
        )

        let router = ArchiveWrapperRouter(
            interactor: interactor,
            viewController: viewController,
            addArchiveBuilder: component.addArchiveBuilder,
            archiveSearchBuilder: component.archiveSearchBuilder,
            archiveFolderBuilder: component.archiveFolderBuilder
        )
        interactor.router = router

        return router
    }
}
