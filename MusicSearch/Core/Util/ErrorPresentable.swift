//
//  ErrorPresentable.swift
//  MusicSearch
//
//  Created by Kiseok on 2/22/26.
//

import UIKit

@MainActor
protocol ErrorPresentable: AnyObject {
	var lastPresentedErrorMessage: String? { get set }
}

@MainActor
extension ErrorPresentable where Self: UIViewController {
	func presentErrorIfNeeded(
		_ message: String?,
		title: String = "오류",
		confirmTitle: String = "확인",
		cancelTitle: String = "취소",
		retryTitle: String = "재시도",
		onRetry: (() -> Void)? = nil
	) {
		guard let message, !message.isEmpty else {
			self.lastPresentedErrorMessage = nil
			return
		}
		guard self.lastPresentedErrorMessage != message else { return }
		guard self.presentedViewController == nil else { return }
		self.lastPresentedErrorMessage = message

		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		if let onRetry {
			alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
			alert.addAction(UIAlertAction(title: retryTitle, style: .default, handler: { _ in
				onRetry()
			}))
		} else {
			alert.addAction(UIAlertAction(title: confirmTitle, style: .default))
		}
		self.present(alert, animated: true)
	}
}
