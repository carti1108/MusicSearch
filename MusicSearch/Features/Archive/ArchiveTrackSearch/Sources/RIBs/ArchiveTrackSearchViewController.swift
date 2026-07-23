import UIKit
import SwiftUI
import MicroRIBs
import ComposableArchitecture

@MainActor
public protocol ArchiveTrackSearchPresentableListener: AnyObject {
	func archiveTrackSearchDidClose()
}

public final class ArchiveTrackSearchViewController: UIHostingController<ArchiveTrackSearchView>, ArchiveTrackSearchPresentable, ArchiveTrackSearchViewControllable, UIAdaptivePresentationControllerDelegate {
	public var uiviewController: UIViewController { self }
	public weak var listener: ArchiveTrackSearchPresentableListener?

	override init(rootView: ArchiveTrackSearchView) {
		super.init(rootView: rootView)
		self.presentationController?.delegate = self
	}

	@MainActor required dynamic init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		listener?.archiveTrackSearchDidClose()
	}
}
