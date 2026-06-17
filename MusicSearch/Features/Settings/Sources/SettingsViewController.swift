import UIKit
import SwiftUI
import MicroRIBs
import MSDesignSystem
import FeatureSettingsInterface

public protocol SettingsViewControllable: ViewControllable {
}

public protocol SettingsPresentable: Presentable {
    var listener: SettingsPresentableListener? { get set }
    func update(state: SettingsViewState)
}



public final class SettingsViewController: UIViewController, SettingsPresentable, SettingsViewControllable {
    public weak var listener: SettingsPresentableListener? {
        didSet {
            viewModel.listener = listener
        }
    }
    
    private let viewModel: SettingsViewModel
    private lazy var hostingController: UIHostingController<SettingsView> = {
        let view = SettingsView(viewModel: viewModel)
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        return controller
    }()

    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
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
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupNavigation() {
        self.title = "설정"
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
        // Left empty since it's a root tab now
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
    
    public func update(state: SettingsViewState) {
        viewModel.update(state: state)
    }
}
