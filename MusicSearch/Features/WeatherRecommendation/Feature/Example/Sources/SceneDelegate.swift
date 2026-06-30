import UIKit
import WeatherRecommendationDomain
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

        let rootVC = router.viewControllable.uiviewController
        let nav = UINavigationController(rootViewController: rootVC)

        let debugButton = UIBarButtonItem(title: "🌤️ 날씨 설정", style: .plain, target: self, action: #selector(showDebugMenu))
        rootVC.navigationItem.rightBarButtonItem = debugButton

        window.rootViewController = nav
        window.makeKeyAndVisible()
    }

    @objc private func showDebugMenu() {
        guard let window = self.window, let rootVC = window.rootViewController else { return }
        let alert = UIAlertController(title: "날씨 설정", message: "시뮬레이션을 원하는 날씨를 선택해주세요.\n선택 후 Pull-to-refresh로 화면을 새로고침 해야 반영됩니다.", preferredStyle: .actionSheet)

        let conditions: [(String, WeatherCondition)] = [
            ("☀️ 맑음 (Clear)", .clear),
            ("☁️ 구름 (Clouds)", .clouds),
            ("🌧️ 비 (Rain)", .rain),
            ("❄️ 눈 (Snow)", .snow),
            ("🌩️ 천둥번개 (Thunderstorm)", .thunderstorm)
        ]

        for (title, condition) in conditions {
            alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                ExampleWeatherState.currentCondition = condition
            }))
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        rootVC.present(alert, animated: true)
    }
}

@MainActor
final class MockWeatherRecommendationListener: WeatherRecommendationListener {}
