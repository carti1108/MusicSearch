import MSUtil

import UIKit
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import WeatherRecommendationDomain
import FeatureWeatherRecommendationTesting

enum DemoScenario: String, CaseIterable {
    case sunny = "☀️ 맑음 (데이터 정상)"
    case rain = "🌧️ 비 (데이터 없음)"
    case snow = "❄️ 눈 (네트워크 에러)"
    case thunderstorm = "🌩️ 천둥번개 (로딩 지연)"
    
    var weatherCondition: WeatherCondition {
        switch self {
        case .sunny: return .clear
        case .rain: return .rain
        case .snow: return .snow
        case .thunderstorm: return .thunderstorm
        }
    }
}

final class DemoListViewController: UITableViewController {
    private var currentRouter: WeatherRecommendationRouting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "시나리오 선택 (WeatherRecommendation)"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DemoScenario.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = DemoScenario.allCases[indexPath.row].rawValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let scenario = DemoScenario.allCases[indexPath.row]
        let component = ExampleAppComponent(scenario: scenario)
        let builder = WeatherRecommendationBuilder(dependency: component)
        
        let router = builder.build(withListener: MockWeatherRecommendationListener())
        self.currentRouter = router
        
        router.interactable.activate()
        router.load()
        
        let vc = router.viewControllable.uiviewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
