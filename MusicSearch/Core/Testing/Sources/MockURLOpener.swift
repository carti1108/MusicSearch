import Foundation
import UIKit
import MSUtil

@MainActor
public final class MockURLOpener: URLOpening, Sendable {
    public var openedURLs: [URL] = []
    public var openedURL: URL?
    public var openCallCount = 0
    public var showAlertOnOpen: Bool

    public init(showAlertOnOpen: Bool = false) {
        self.showAlertOnOpen = showAlertOnOpen
    }

    public func open(_ url: URL) {
        self.openedURLs.append(url)
        self.openedURL = url
        self.openCallCount += 1

        if showAlertOnOpen {
            Task { @MainActor in
                let alert = UIAlertController(title: "URL Routing", message: "딥링크 이동:\n\(url.absoluteString)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                    var topVC = rootVC
                    while let presented = topVC.presentedViewController {
                        topVC = presented
                    }
                    topVC.present(alert, animated: true)
                }
            }
        }
    }
}
