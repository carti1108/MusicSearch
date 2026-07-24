import MicroRIBs
import FeatureArchiveInterface

public protocol ArchiveInteractable: Interactable {
    var router: ArchiveRouting? { get set }
    var listener: ArchiveListener? { get set }
}

public final class ArchiveInteractor: Interactor, ArchiveInteractable {
    public weak var router: ArchiveRouting?
    public weak var listener: ArchiveListener?
}
