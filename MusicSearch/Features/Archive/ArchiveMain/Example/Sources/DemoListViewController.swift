import MSUtil

import UIKit
import FeatureArchive
import FeatureArchiveInterface
import ArchiveDomain

enum DemoScenario: String, CaseIterable {
    case success = "✅ 성공 (데이터 정상)"
    case empty = "📭 빈 화면 (데이터 없음)"
    case error = "⚠️ 에러 (네트워크 실패)"
    case delayed = "⏳ 지연 (로딩 2초)"
}

final class DemoListViewController: UIViewController {
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "ArchiveMain Scenarios"
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
        let builder = ArchiveBuilder(dependency: component)
        let router = builder.build(withListener: MockArchiveListener())
        
        router.load()
        router.interactable.activate()
        
        let vc = router.viewControllable.uiviewController
        vc.modalPresentationStyle = .fullScreen
        
        let nav = UINavigationController(rootViewController: vc)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeDemo))
        
        present(nav, animated: true)
    }
    
    @objc private func closeDemo() {
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
final class MockArchiveListener: ArchiveListener {}

@MainActor
final class MockURLOpener: URLOpening {
    func open(_ url: URL) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "URL Routing", message: "딥링크 이동:\n\(url.absoluteString)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                topVC.present(alert, animated: true)
            }
        }
    }
}
