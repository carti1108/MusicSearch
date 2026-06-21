import UIKit
import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window
    }
}
