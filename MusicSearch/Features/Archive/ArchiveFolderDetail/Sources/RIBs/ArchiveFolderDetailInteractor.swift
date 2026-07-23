import MicroRIBs
import ArchiveDomain
import FeatureArchiveFolderDetailInterface

@MainActor
public protocol ArchiveFolderDetailPresentable: Presentable {
    var listener: ArchiveFolderDetailPresentableListener? { get set }
    func showLoginPrompt()
}



public final class ArchiveFolderDetailInteractor: PresentableInteractor<ArchiveFolderDetailPresentable>, ArchiveFolderDetailInteractable, ArchiveFolderDetailPresentableListener {
    public weak var router: ArchiveFolderDetailRouting?
    public weak var listener: ArchiveFolderDetailListener?

    public override init(presenter: ArchiveFolderDetailPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    public func archiveFolderDetailDidTapClose() {
        listener?.archiveFolderDetailDidTapClose()
    }

    public func showLoginPrompt() {
        presenter.showLoginPrompt()
    }

    public func archiveFolderDetailDidTapFolder(_ folderItem: FolderItem) {
        listener?.archiveFolderDetailDidTapFolder(folderItem)
    }

    public func archiveFolderDetailDidTapTrack(_ track: ArchivedTrack) {
        listener?.archiveFolderDetailDidTapTrack(track)
    }
}
