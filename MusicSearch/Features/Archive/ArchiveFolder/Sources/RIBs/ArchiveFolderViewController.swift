import UIKit
import SwiftUI
import MicroRIBs
import ComposableArchitecture

@MainActor
public protocol ArchiveFolderPresentableListener: AnyObject {
    func archiveFolderDidTapClose()
}

public final class ArchiveFolderViewController: UIHostingController<ArchiveFolderView>, ArchiveFolderPresentable, ArchiveFolderViewControllable {
    public var uiviewController: UIViewController { self }
    public weak var listener: ArchiveFolderPresentableListener?

    override init(rootView: ArchiveFolderView) {
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "보관함 폴더"
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.archiveFolderDidTapClose()
        }
    }
}
