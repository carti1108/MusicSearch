import MicroRIBs

public protocol SettingsBuildable: Buildable {
    func build(withListener listener: SettingsListener) -> SettingsRouting
}

public protocol SettingsRouting: ViewableRouting {
}

public protocol SettingsListener: AnyObject {
}
