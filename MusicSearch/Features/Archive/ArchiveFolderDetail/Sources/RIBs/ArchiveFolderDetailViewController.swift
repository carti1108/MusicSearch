import UIKit
import SwiftUI
import MicroRIBs
import ComposableArchitecture
import ArchiveDomain

@MainActor
public protocol ArchiveFolderDetailPresentableListener: AnyObject {
    func archiveFolderDetailDidTapClose()
}

public final class ArchiveFolderDetailViewController: UIHostingController<ArchiveFolderDetailView>, ArchiveFolderDetailPresentable, ArchiveFolderDetailViewControllable {
    public var uiviewController: UIViewController { self }
    public weak var listener: ArchiveFolderDetailPresentableListener?
    private let store: StoreOf<ArchiveFolderDetailFeature>

    init(rootView: ArchiveFolderDetailView, store: StoreOf<ArchiveFolderDetailFeature>) {
        self.store = store
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.archiveFolderDetailDidTapClose()
        }
    }

    private func setupNavigation() {
        self.title = store.title

        var showExportButton = false
        switch store.folderItem.type {
        case .releaseYear, .listenYear, .releaseMonth, .listenMonth:
            showExportButton = false
        default:
            showExportButton = true
        }

        if showExportButton {
            let exportButton = UIBarButtonItem(
                title: "플레이리스트 내보내기",
                style: .plain,
                target: self,
                action: #selector(exportButtonTapped)
            )
            self.navigationItem.rightBarButtonItem = exportButton
        }
    }

    @objc private func exportButtonTapped() {
        store.send(.exportButtonTapped)
    }

    public func showLoginPrompt() {
        let alert = UIAlertController(
            title: "연동 필요",
            message: "플레이리스트를 내보내려면 스포티파이 연동이 필요합니다. 지금 연동하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "연동하기", style: .default) { [weak self] _ in
            self?.store.send(.loginPromptTapped)
        })
        self.present(alert, animated: true)
    }
}
