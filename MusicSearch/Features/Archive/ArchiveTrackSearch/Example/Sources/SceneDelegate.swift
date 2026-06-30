import UIKit
import MicroRIBs
import FeatureArchiveTrackSearch
import FeatureArchiveTrackSearchInterface

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
        let builder = ArchiveTrackSearchBuilder(dependency: component)
        let router = builder.build(withListener: MockArchiveTrackSearchListener(), editTrack: nil)
        
        self.router = router
        router.interactable.activate()
        router.load()
        
        window.rootViewController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockArchiveTrackSearchListener: ArchiveTrackSearchListener {
    func didCloseArchiveTrackSearch() {}
}
