import UIKit
import Testing
@testable import MusicSearch

@MainActor
struct RootViewControllerTests {
	@Test
	func viewDidLoad하면_tabBarAppearance가설정되는지() {
		let viewController = RootViewController()

		viewController.loadViewIfNeeded()

		#expect(viewController.tabBar.scrollEdgeAppearance != nil)
		#expect(viewController.tabBar.tintColor != nil)
		#expect(viewController.tabBar.unselectedItemTintColor != nil)
		#expect(viewController.tabBar.isTranslucent == true)
		#expect(viewController.tabBar.layer.cornerRadius == 26)
	}

	@Test
	func setTabs를호출하면_전달한뷰컨트롤러들이탭으로설정되는지() {
		let viewController = RootViewController()
		let first = UIViewController()
		let second = UIViewController()
		let third = UIViewController()

		viewController.setTabs([first, second, third])

		#expect(viewController.viewControllers?.count == 3)
		#expect(viewController.viewControllers?[0] === first)
		#expect(viewController.viewControllers?[1] === second)
		#expect(viewController.viewControllers?[2] === third)
	}
}
