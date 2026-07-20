//
//  DemoListViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 7/10/26.
//

import MSUtil

import UIKit
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import MusicDiggingDomain
import FeatureMusicDiggingTesting
import MSDomain
import FeatureMusicDiggingTesting

enum DemoScenario: String, CaseIterable {
    case success = "✅ 성공 (데이터 정상)"
    case empty = "📭 빈 화면 (데이터 없음)"
    case error = "⚠️ 에러 (네트워크 실패)"
    case delayed = "⏳ 지연 (로딩 2초)"
}

final class DemoListViewController: UIViewController {
    
    private let tableView = UITableView()
    private var currentRouter: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "MusicDigging Scenarios"
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
        let builder = MusicDiggingBuilder(dependency: component)
        let seedTrack = Track(title: "Sample Track", artist: "Sample Artist", imageURL: nil)
        let router = builder.build(withListener: MockMusicDiggingListener(), seedTrack: seedTrack)
        self.currentRouter = router
        
        router.load()
        router.interactable.activate()
        
        let vc = router.viewControllable.uiviewController
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        // Add a close button
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

@MainActor
final class MockMusicDiggingListener: MusicDiggingListener {}

@MainActor
final class MockURLOpener: URLOpening {
    func open(_ url: URL) {
        Task { @MainActor in
            let alert = UIAlertController(title: "URL Routing", message: "딥링크 이동:\n\(url.absoluteString)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                topVC.present(alert, animated: true)
            }
        }
    }
}
