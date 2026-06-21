import UIKit
import SwiftUI
import MicroRIBs
import MSDesignSystem
import ArchiveDomain
import FeatureArchiveFolderDetailInterface

public protocol ArchiveFolderDetailPresentableListener: AnyObject {
    func didTapClose()
    func didTapFolder(_ folder: FolderItem)
    func didTapTrack(_ track: ArchivedTrack)
    func didTapExport()
    func didTapLogin()
}

public final class ArchiveFolderDetailViewController: UIViewController, ArchiveFolderDetailPresentable, ArchiveFolderDetailViewControllable {
    public weak var listener: ArchiveFolderDetailPresentableListener?

    private var viewModel = ArchiveFolderDetailViewModel(state: ArchiveFolderDetailViewState(title: ""))
    private lazy var hostingController: UIHostingController<ArchiveFolderDetailView> = {
        let view = ArchiveFolderDetailView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        return controller
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(CustomColor.background)
        
        setupNavigation()
        setupUI()
        
        viewModel.onAction = { [weak self] action in
            switch action {
            case .onFolderTapped(let folder):
                self?.listener?.didTapFolder(folder)
            case .onTrackTapped(let track):
                self?.listener?.didTapTrack(track)
            case .onExportTapped:
                self?.listener?.didTapExport()
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.didTapClose()
        }
    }
    
    public func update(state: ArchiveFolderDetailViewState) {
        viewModel.state = state
        self.title = state.title
        
        if state.tracks != nil {
            let exportButton = UIBarButtonItem(
                title: "플레이리스트 내보내기",
                style: .plain,
                target: self,
                action: #selector(exportButtonTapped)
            )
            exportButton.tintColor = UIColor(CustomColor.primary)
            self.navigationItem.rightBarButtonItem = exportButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func exportButtonTapped() {
        listener?.didTapExport()
    }

    private func setupNavigation() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = UIColor(CustomColor.primary)
        self.navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        listener?.didTapClose()
    }

    private func setupUI() {
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    public func push(viewController: ViewControllable, animated: Bool) {
        self.navigationController?.pushViewController(viewController.uiviewController, animated: animated)
    }

    public func pop(animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
    }
    
    public func showLoginPrompt() {
        let alert = UIAlertController(
            title: "연동 필요",
            message: "플레이리스트를 내보내려면 스포티파이 연동이 필요합니다. 지금 연동하시겠습니까?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "연동하기", style: .default) { [weak self] _ in
            self?.listener?.didTapLogin()
        })
        self.present(alert, animated: true)
    }
}
