import UIKit
import FeatureArchive
import FeatureArchiveInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	private var router: ArchiveRouting?

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let demoListVC = DemoListViewController()
        let nav = UINavigationController(rootViewController: demoListVC)
        window.rootViewController = nav
        window.makeKeyAndVisible()
	}
}

