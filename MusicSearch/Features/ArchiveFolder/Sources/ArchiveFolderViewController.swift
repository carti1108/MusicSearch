import UIKit
import SwiftUI
import MicroRIBs
import MSDesignSystem
import ArchiveDomain
import FeatureArchiveFolderInterface

public protocol ArchiveFolderViewControllable: ViewControllable {
    func push(viewController: ViewControllable, animated: Bool)
    func pop(animated: Bool)
}

public protocol ArchiveFolderPresentable: Presentable {
    var listener: ArchiveFolderPresentableListener? { get set }
}

public protocol ArchiveFolderPresentableListener: AnyObject {
    func didTapClose()
    func didTapFolder(_ folder: FolderItem)
}

public final class ArchiveFolderViewController: UIViewController, ArchiveFolderPresentable, ArchiveFolderViewControllable {
    public weak var listener: ArchiveFolderPresentableListener?
    
    private let viewModel: ArchiveFolderViewModel
    private lazy var hostingController: UIHostingController<ArchiveFolderView> = {
        let view = ArchiveFolderView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        return controller
    }()

    public init(viewModel: ArchiveFolderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.onFolderTapped = { [weak self] folder in
            self?.listener?.didTapFolder(folder)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(CustomColor.background)
        
        setupNavigation()
        setupUI()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.didTapClose()
        }
    }
    
    private func setupNavigation() {
        self.title = "보관함 폴더"
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
}
