import Foundation
import UIKit
import SwiftUI
import ComposableArchitecture
import MicroRIBs
import FeatureSettingsInterface
import MSDomain

@MainActor
public protocol SettingsDependency: MicroRIBs.Dependency {
    var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase { get }
    var authorizeMusicUseCase: AuthorizeMusicUseCase { get }
    var disconnectMusicUseCase: DisconnectMusicUseCase { get }
    var fetchUserProfileUseCase: FetchUserProfileUseCase { get }
}

final class SettingsComponent: Component<SettingsDependency> {
}

public protocol SettingsInteractable: Interactable {
    var router: SettingsRouting? { get set }
    var listener: SettingsListener? { get set }
}

public final class SettingsWrapperInteractor: Interactor, SettingsInteractable {
    public weak var router: SettingsRouting?
    public weak var listener: SettingsListener?
}

public final class SettingsHostingController: UIHostingController<SettingsView>, ViewControllable {
    public var uiviewController: UIViewController { self }
}

public final class SettingsWrapperRouter: ViewableRouter<SettingsInteractable, ViewControllable>, SettingsRouting {
}

public final class SettingsBuilder: Builder<SettingsDependency>, SettingsBuildable {

    public override init(dependency: SettingsDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: SettingsListener) -> SettingsRouting {
        let component = SettingsComponent(dependency: dependency)

        let interactor = SettingsWrapperInteractor()
        interactor.listener = listener

        let store = Store(initialState: SettingsFeature.State()) {
            SettingsFeature(
                getMusicAccessTokenUseCase: component.dependency.getMusicAccessTokenUseCase,
                authorizeMusicUseCase: component.dependency.authorizeMusicUseCase,
                disconnectMusicUseCase: component.dependency.disconnectMusicUseCase,
                fetchUserProfileUseCase: component.dependency.fetchUserProfileUseCase
            )
        }

        let view = SettingsView(store: store)
        let viewController = SettingsHostingController(rootView: view)
        viewController.view.backgroundColor = .clear

        let router = SettingsWrapperRouter(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = router

        return router
    }
}
