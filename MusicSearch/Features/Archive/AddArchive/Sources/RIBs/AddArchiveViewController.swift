import UIKit
import SwiftUI
import MicroRIBs
import ComposableArchitecture

@MainActor
public protocol AddArchivePresentableListener: AnyObject {
	func didCloseAddArchive()
}

public final class AddArchiveViewController: UIHostingController<AddArchiveView>, AddArchivePresentable, AddArchiveViewControllable, UIAdaptivePresentationControllerDelegate {
	public var uiviewController: UIViewController { self }
	public weak var listener: AddArchivePresentableListener?

	override init(rootView: AddArchiveView) {
		super.init(rootView: rootView)
		self.presentationController?.delegate = self
	}

	@MainActor required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		listener?.didCloseAddArchive()
	}
}
