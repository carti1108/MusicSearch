import UIKit
import SwiftUI
import MicroRIBs
import ComposableArchitecture

@MainActor
public protocol ArchiveSearchPresentableListener: AnyObject {
    func archiveSearchDidTapClose()
}

public final class ArchiveSearchViewController: UIHostingController<ArchiveSearchView>, ArchiveSearchPresentable, ArchiveSearchViewControllable {
    public var uiviewController: UIViewController { self }
    public weak var listener: ArchiveSearchPresentableListener?

    override init(rootView: ArchiveSearchView) {
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.archiveSearchDidTapClose()
        }
    }
}
