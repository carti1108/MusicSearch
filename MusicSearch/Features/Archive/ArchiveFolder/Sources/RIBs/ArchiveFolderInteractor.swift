import MicroRIBs
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import ArchiveDomain

@MainActor
public protocol ArchiveFolderPresentable: Presentable {
    var listener: ArchiveFolderPresentableListener? { get set }
}



public final class ArchiveFolderInteractor: PresentableInteractor<ArchiveFolderPresentable>, ArchiveFolderInteractable, ArchiveFolderPresentableListener {
    public weak var router: ArchiveFolderRouting?
    public weak var listener: ArchiveFolderListener?

    public override init(presenter: ArchiveFolderPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    public func archiveFolderDidTapClose() {
        listener?.archiveFolderDidTapClose()
    }

    public func archiveFolderDetailDidTapClose() {
        router?.detachFolderDetail(popUI: false)
    }

    public func archiveFolderDetailDidTapFolder(_ folderItem: FolderItem) {
        router?.routeToFolderDetail(folderItem: folderItem)
    }

    public func archiveFolderDetailDidTapTrack(_ track: ArchivedTrack) {
        listener?.archiveFolderDidTapTrack(track)
    }
}
