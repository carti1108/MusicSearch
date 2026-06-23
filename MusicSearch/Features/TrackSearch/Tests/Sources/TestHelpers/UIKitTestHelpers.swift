import Foundation
import UIKit

@MainActor
extension UIView {
	func findSubview<T: UIView>(ofType type: T.Type) -> T? {
		if let view = self as? T {
			return view
		}

		for subview in self.subviews {
			if let matched = subview.findSubview(ofType: type) {
				return matched
			}
		}

		return nil
	}

	func findSubviews<T: UIView>(ofType type: T.Type) -> [T] {
		var matched: [T] = []
		if let view = self as? T {
			matched.append(view)
		}

		for subview in self.subviews {
			matched.append(contentsOf: subview.findSubviews(ofType: type))
		}

		return matched
	}
}

@MainActor
func flushMainQueue() async {
	await Task.yield()
	try? await Task.sleep(nanoseconds: 10_000_000)
	await Task.yield()
}
