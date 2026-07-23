import MicroRIBs
import FeatureAddArchiveInterface
import FeatureArchiveTrackSearchInterface
import MSDomain

@MainActor
public protocol AddArchivePresentable: Presentable {
	var listener: AddArchivePresentableListener? { get set }
}



public final class AddArchiveInteractor: PresentableInteractor<AddArchivePresentable>, AddArchiveInteractable, AddArchivePresentableListener {
	public weak var router: AddArchiveRouting?
	public weak var listener: AddArchiveListener?

	var onTrackSelected: ((Track) -> Void)?

	public override init(presenter: AddArchivePresentable) {
		super.init(presenter: presenter)
		presenter.listener = self
	}

	public func didCloseAddArchive() {
		listener?.didCloseAddArchive()
	}

	// MARK: - ArchiveTrackSearchListener
	public func archiveTrackSearchDidClose() {
		router?.detachArchiveTrackSearch()
	}

	public func archiveTrackSearchDidSelectTrack(_ track: Track) {
		onTrackSelected?(track)
		router?.detachArchiveTrackSearch()
	}
}
