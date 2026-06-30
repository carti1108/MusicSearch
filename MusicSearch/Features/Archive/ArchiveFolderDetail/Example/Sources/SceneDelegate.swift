import UIKit
import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailInterface
import ArchiveDomain

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var router: ArchiveFolderDetailRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let component = ExampleAppComponent()
        let builder = ArchiveFolderDetailBuilder(dependency: component)
        let router = builder.build(withListener: MockArchiveFolderDetailListener(), folderItem: FolderItem(title: "Example Folder", subtitle: "0", type: .custom))
        
        self.router = router
        router.interactable.activate()
        router.load()
        
        window.rootViewController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockArchiveFolderDetailListener: ArchiveFolderDetailListener {
    func archiveFolderDetailDidTapClose() {}
    func archiveFolderDetailDidTapFolder(_ folderItem: FolderItem) {}
    func archiveFolderDetailDidTapTrack(_ track: ArchivedTrack) {}
}
