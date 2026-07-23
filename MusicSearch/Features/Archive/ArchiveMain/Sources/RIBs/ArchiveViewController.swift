import UIKit
import SwiftUI
import MicroRIBs
import ComposableArchitecture

@MainActor
public protocol ArchivePresentableListener: AnyObject {
}



public final class ArchiveViewController: UIHostingController<ArchiveView>, ArchivePresentable, ArchiveViewControllable {
    public var uiviewController: UIViewController { self }
    public weak var listener: ArchivePresentableListener?
    private let store: StoreOf<ArchiveFeature>

    init(rootView: ArchiveView, store: StoreOf<ArchiveFeature>) {
        self.store = store
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "나의 보관함"
        self.tabBarItem.title = "Archive"
        self.tabBarItem.image = UIImage(systemName: "archivebox")
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.send(.onAppear)
    }

    public func push(viewController: ViewControllable, animated: Bool) {
        self.navigationController?.pushViewController(viewController.uiviewController, animated: animated)
    }

    public func pop(animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
    }
}
