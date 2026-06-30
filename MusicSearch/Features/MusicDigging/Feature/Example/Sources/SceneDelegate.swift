import UIKit
import MSDomain
import FeatureMusicDigging
import FeatureMusicDiggingInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var musicDiggingRouter: MusicDiggingRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let component = ExampleAppComponent()
        let builder = MusicDiggingBuilder(dependency: component)
        let mockTrack = Track(title: "Seed Track", artist: "Seed Artist", imageURL: nil)
        let router = builder.build(withListener: MockMusicDiggingListener(), seedTrack: mockTrack)

        self.musicDiggingRouter = router
        router.interactable.activate()
        router.load()

        window.rootViewController = router.viewControllable.uiviewController
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockMusicDiggingListener: MusicDiggingListener {}
