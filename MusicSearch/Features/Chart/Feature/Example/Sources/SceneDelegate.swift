import UIKit
import MicroRIBs
import FeatureChart
import FeatureChartInterface

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var chartRouter: ChartRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let component = ExampleAppComponent()
        let builder = ChartBuilder(dependency: component)
        let router = builder.build(withListener: MockChartListener())

        self.chartRouter = router
        router.interactable.activate()
        router.load()

        window.rootViewController = router.viewControllable.uiviewController
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockChartListener: ChartListener {}
