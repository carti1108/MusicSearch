import Foundation
import UIKit
import Combine
import MicroRIBs
import MSDomain
import FeatureSettingsInterface
@testable import FeatureSettings

public final class MockSettingsRouting: SettingsRouting, @unchecked Sendable {
    public var viewControllable: ViewControllable
    public var interactable: Interactable {
        get { fatalError() }
        set { fatalError() }
    }
    public var children: [Routing] = []
    
    public var lifecycle: AsyncStream<RouterLifecycle> {
        return AsyncStream { _ in }
    }
    
    public init(interactor: Interactable, viewController: ViewControllable) {
        self.viewControllable = viewController
    }
    
    public func load() {}
    public func attachChild(_ child: Routing) {}
    public func detachChild(_ child: Routing) {}
}

public final class MockManageSpotifyAuthUseCase: ManageSpotifyAuthUseCase, @unchecked Sendable {
    public var getAccessTokenResult: String?
    public var authorizeCallCount = 0
    public var disconnectCallCount = 0
    
    public init() {}
    
    public func getAccessToken() -> String? {
        return getAccessTokenResult
    }
    
    public func authorize() async throws {
        authorizeCallCount += 1
    }
    
    public func disconnect() {
        disconnectCallCount += 1
    }
}

public final class MockFetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase, @unchecked Sendable {
    public var executeResult: (name: String, imageURL: URL?) = ("Test User", nil)
    
    public init() {}
    
    public func execute() async throws -> (name: String, imageURL: URL?) {
        return executeResult
    }
}

public final class MockSettingsDependency: SettingsDependency, @unchecked Sendable {
    public var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase
    public var fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase
    
    public init(manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase, fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase) {
        self.manageSpotifyAuthUseCase = manageSpotifyAuthUseCase
        self.fetchSpotifyProfileUseCase = fetchSpotifyProfileUseCase
    }
}

public final class MockSettingsViewControllable: SettingsViewControllable, @unchecked Sendable {
    @MainActor public var uiViewController: UIViewController {
        return UIViewController()
    }
    
    public init() {}
}

public final class MockSettingsInteractable: SettingsInteractable, @unchecked Sendable {
    public var router: SettingsRouting?
    public var listener: SettingsListener?
    public var isActive: Bool = true
    public var isActiveStream: MicroRIBs.Observable<Bool> {
        return AsyncStream { _ in }
    }
    
    public init() {}
    
    public func activate() {}
    public func deactivate() {}
}
