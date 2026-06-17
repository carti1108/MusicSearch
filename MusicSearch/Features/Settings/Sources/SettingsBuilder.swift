import MicroRIBs
import FeatureSettingsInterface
import NetworkLayer

public protocol SettingsDependency: Dependency {
    var networkManager: NetworkRequesting { get }
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
        let interactor = SettingsInteractor(presenter: viewController, networkManager: component.dependency.networkManager)
        interactor.listener = listener
        return SettingsRouter(interactor: interactor, viewController: viewController)
    }
}
