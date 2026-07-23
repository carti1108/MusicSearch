import MicroRIBs
import FeatureArchiveSearchInterface

@MainActor
public protocol ArchiveSearchInteractable: Interactable {
    var router: ArchiveSearchRouting? { get set }
    var listener: ArchiveSearchListener? { get set }
}

@MainActor
public protocol ArchiveSearchViewControllable: ViewControllable {
}

public final class ArchiveSearchRouter: ViewableRouter<ArchiveSearchInteractable, ArchiveSearchViewControllable>, ArchiveSearchRouting {
}
