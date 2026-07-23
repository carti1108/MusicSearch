import MicroRIBs
import FeatureArchiveSearchInterface

@MainActor
public protocol ArchiveSearchPresentable: Presentable {
    var listener: ArchiveSearchPresentableListener? { get set }
}



public final class ArchiveSearchInteractor: PresentableInteractor<ArchiveSearchPresentable>, ArchiveSearchInteractable, ArchiveSearchPresentableListener {
    public weak var router: ArchiveSearchRouting?
    public weak var listener: ArchiveSearchListener?

    public override init(presenter: ArchiveSearchPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    public func archiveSearchDidTapClose() {
        listener?.archiveSearchDidTapClose()
    }
}
