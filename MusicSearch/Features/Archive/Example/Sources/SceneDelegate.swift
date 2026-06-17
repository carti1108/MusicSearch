import UIKit
import FeatureArchive
import FeatureArchiveInterface

final class ExampleArchiveComponent: ArchiveDependency {
}

final class MockArchiveListener: ArchiveListener {
}

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
		
		let component = ExampleArchiveComponent()
		let builder = ArchiveBuilder(dependency: component)
		let router = builder.build(withListener: MockArchiveListener())
		self.router = router
		
		window.rootViewController = router.viewControllable.uiviewController
		window.makeKeyAndVisible()
		self.window = window
	}
}
