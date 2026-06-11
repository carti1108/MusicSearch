import UIKit
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var weatherRecommendationRouter: WeatherRecommendationRouting?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let component = ExampleAppComponent()
        let builder = WeatherRecommendationBuilder(dependency: component)
        let router = builder.build(withListener: MockWeatherRecommendationListener())
        
        self.weatherRecommendationRouter = router
        router.interactable.activate()
        router.load()
        
        window.rootViewController = router.viewControllable.uiviewController
        window.makeKeyAndVisible()
    }
}

@MainActor
final class MockWeatherRecommendationListener: WeatherRecommendationListener {}
