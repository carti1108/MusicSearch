import MicroRIBs
import FeatureArchiveTrackSearchInterface

@MainActor
public protocol ArchiveTrackSearchPresentable: Presentable {
	var listener: ArchiveTrackSearchPresentableListener? { get set }
}



public final class ArchiveTrackSearchInteractor: PresentableInteractor<ArchiveTrackSearchPresentable>, ArchiveTrackSearchInteractable, ArchiveTrackSearchPresentableListener {
	public weak var router: ArchiveTrackSearchRouting?
	public weak var listener: ArchiveTrackSearchListener?

	public override init(presenter: ArchiveTrackSearchPresentable) {
		super.init(presenter: presenter)
		presenter.listener = self
	}

	public func archiveTrackSearchDidClose() {
		listener?.archiveTrackSearchDidClose()
	}
}
