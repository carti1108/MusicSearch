import MicroRIBs
import FeatureArchiveInterface
import ArchiveDomain
import FeatureAddArchiveInterface
import FeatureArchiveFolderInterface
import FeatureArchiveSearchInterface

@MainActor
public protocol ArchivePresentable: Presentable {
    var listener: ArchivePresentableListener? { get set }
}

public final class ArchiveInteractor: PresentableInteractor<ArchivePresentable>, ArchiveInteractable, ArchivePresentableListener {
    public weak var router: ArchiveRouting?
    public weak var listener: ArchiveListener?
    public var onRefresh: (() -> Void)?

    public override init(presenter: ArchivePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

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
