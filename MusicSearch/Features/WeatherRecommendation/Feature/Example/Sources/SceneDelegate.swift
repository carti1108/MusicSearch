import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Start with the Demo Gallery
        let rootVC = DemoListViewController()
        let nav = UINavigationController(rootViewController: rootVC)

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}
