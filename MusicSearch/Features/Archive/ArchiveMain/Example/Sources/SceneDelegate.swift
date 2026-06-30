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

		let component = ExampleAppComponent()
        let builder = ArchiveBuilder(dependency: component)
        let router = builder.build(withListener: MockArchiveListener())

        self.router = router
        router.interactable.activate()
        router.load()

        window.rootViewController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        window.makeKeyAndVisible()
		self.window = window
	}
}

@MainActor
final class MockArchiveListener: ArchiveListener {}
