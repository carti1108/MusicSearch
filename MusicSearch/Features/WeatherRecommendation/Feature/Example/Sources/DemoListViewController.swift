//
//  DemoListViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 7/10/26.
//

import UIKit
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import FeatureWeatherRecommendationTesting
import MSTesting
import MSUtil
import WeatherRecommendationDomain

enum DemoScenario: String, CaseIterable {
    case sunny = "☀️ 맑음 (신나는 음악)"
    case rain = "🌧 비 (감성적인 음악)"
    case snow = "❄️ 눈 (에러 발생)"
    case thunderstorm = "⚡️ 천둥번개 (로딩 지연)"
}

final class DemoListViewController: UIViewController {
    
    private let tableView = UITableView()
    private var currentRouter: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Weather Recommendation Scenarios"
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func launchScenario(_ scenario: DemoScenario) {
        let component = ExampleAppComponent(scenario: scenario)
        let builder = WeatherRecommendationBuilder(dependency: component)
        let router = builder.build(withListener: MockWeatherRecommendationListener())
        self.currentRouter = router
        
        router.load()
        router.interactable.activate()
        
        let vc = router.viewControllable.uiviewController
        vc.modalPresentationStyle = .fullScreen
        
        let nav = UINavigationController(rootViewController: vc)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeDemo))
        
        present(nav, animated: true)
    }
    
    @objc private func closeDemo() {
        self.currentRouter = nil
        dismiss(animated: true)
    }
}

extension DemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DemoScenario.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = DemoScenario.allCases[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        launchScenario(DemoScenario.allCases[indexPath.row])
    }
}

