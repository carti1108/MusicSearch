import UIKit
import FeatureTrackSearch
import FeatureTrackSearchInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var trackSearchRouter: TrackSearchRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let component = ExampleAppComponent()
        let builder = TrackSearchBuilder(dependency: component)
        let navigationController = UINavigationController()
        let router = builder.build(withListener: MockTrackSearchListener(), navigationController: navigationController)

        self.trackSearchRouter = router
        router.interactable.activate()
        router.load()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockTrackSearchListener: TrackSearchListener {}
