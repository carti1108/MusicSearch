import UIKit
import MicroRIBs
import FeatureArchiveFolder
import FeatureArchiveFolderInterface
import ArchiveDomain

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
        let builder = ArchiveFolderBuilder(dependency: component)
        let router = builder.build(withListener: MockArchiveFolderListener())

        self.router = router
        router.interactable.activate()
        router.load()

        window.rootViewController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockArchiveFolderListener: ArchiveFolderListener {
    func archiveFolderDidTapClose() {}
    func archiveFolderDidTapTrack(_ track: ArchivedTrack) {}
}
