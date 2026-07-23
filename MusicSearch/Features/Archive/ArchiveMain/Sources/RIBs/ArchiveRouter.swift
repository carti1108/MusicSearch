import MicroRIBs
import FeatureArchiveInterface
import FeatureAddArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import ArchiveDomain

@MainActor
public protocol ArchiveInteractable: Interactable, AddArchiveListener, ArchiveSearchListener, ArchiveFolderListener {
    var router: ArchiveRouting? { get set }
    var listener: ArchiveListener? { get set }
}

@MainActor
public protocol ArchiveViewControllable: ViewControllable {
    func push(viewController: ViewControllable, animated: Bool)
    func pop(animated: Bool)
}

public final class ArchiveRouter: ViewableRouter<ArchiveInteractable, ArchiveViewControllable>, ArchiveRouting {

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
