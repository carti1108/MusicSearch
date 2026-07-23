import MicroRIBs
import FeatureArchiveTrackSearchInterface

@MainActor
public protocol ArchiveTrackSearchInteractable: Interactable {
	var router: ArchiveTrackSearchRouting? { get set }
	var listener: ArchiveTrackSearchListener? { get set }
}

@MainActor
public protocol ArchiveTrackSearchViewControllable: ViewControllable {
}

public final class ArchiveTrackSearchRouter: ViewableRouter<ArchiveTrackSearchInteractable, ArchiveTrackSearchViewControllable>, ArchiveTrackSearchRouting {
}
