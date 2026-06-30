import UIKit
import MicroRIBs
import FeatureSettings
import FeatureSettingsInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var router: ViewableRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let component = ExampleAppComponent()
        let builder = SettingsBuilder(dependency: component)
        let router = builder.build(withListener: MockSettingsListener())

        self.router = router
        router.interactable.activate()
        router.load()

        window.rootViewController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockSettingsListener: SettingsListener {}
