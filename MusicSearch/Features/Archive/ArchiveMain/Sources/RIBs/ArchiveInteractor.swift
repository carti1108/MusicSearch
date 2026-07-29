import MicroRIBs
import FeatureArchiveInterface

@MainActor
public protocol ArchiveInteractable: Interactable {
    var router: ArchiveRouting? { get set }
    var listener: ArchiveListener? { get set }
}

@MainActor
public final class ArchiveInteractor: Interactor, ArchiveInteractable {
    public weak var router: ArchiveRouting?
    public weak var listener: ArchiveListener?
}
