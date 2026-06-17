import UIKit
import SwiftUI
import MicroRIBs
import MSDesignSystem

public final class ArchiveViewController: UIViewController, ArchivePresentable, ArchiveViewControllable {

	public weak var listener: ArchivePresentableListener?
	
	private let viewModel: ArchiveViewModel
	private lazy var hostingController: UIHostingController<ArchiveView> = {
		let view = ArchiveView(viewModel: viewModel)
		let controller = UIHostingController(rootView: view)
		controller.view.backgroundColor = .clear
		return controller
	}()

	public init(viewModel: ArchiveViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(CustomColor.background)
		
		self.navigationItem.title = "나의 보관함"
		self.tabBarItem.title = "Archive"
		self.tabBarItem.image = UIImage(systemName: "archivebox")
		
		setupSwiftUIView()
	}
	
	private func setupSwiftUIView() {
		addChild(hostingController)
		view.addSubview(hostingController.view)
		hostingController.didMove(toParent: self)
		
		hostingController.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
			hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
	
	public func push(viewController: ViewControllable, animated: Bool) {
		self.navigationController?.pushViewController(viewController.uiviewController, animated: animated)
	}

	public func pop(animated: Bool) {
		self.navigationController?.popViewController(animated: animated)
	}
}
