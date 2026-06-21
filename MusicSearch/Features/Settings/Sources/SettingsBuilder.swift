import MicroRIBs
import FeatureSettingsInterface
import MSDomain

@MainActor
public protocol SettingsDependency: Dependency {
    var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase { get }
    var fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase { get }
}

final class SettingsComponent: Component<SettingsDependency> {
}

public final class SettingsBuilder: Builder<SettingsDependency>, SettingsBuildable {

    public override init(dependency: SettingsDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: SettingsListener) -> SettingsRouting {
        let component = SettingsComponent(dependency: dependency)
        let viewModel = SettingsViewModel()
        let viewController = SettingsViewController(viewModel: viewModel)
        let interactor = SettingsInteractor(
            presenter: viewController,
            manageSpotifyAuthUseCase: component.dependency.manageSpotifyAuthUseCase,
            fetchSpotifyProfileUseCase: component.dependency.fetchSpotifyProfileUseCase
        )
        interactor.listener = listener
        return SettingsRouter(interactor: interactor, viewController: viewController)
    }
}
