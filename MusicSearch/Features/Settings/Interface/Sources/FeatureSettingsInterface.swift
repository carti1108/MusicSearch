//
//  FeatureSettingsInterface.swift
//  MusicSearch
//
//  Created by Kiseok on 6/17/26.
//

import MicroRIBs

public protocol SettingsBuildable: Buildable {
    func build(withListener listener: SettingsListener) -> SettingsRouting
}

public protocol SettingsRouting: ViewableRouting {
}

public protocol SettingsListener: AnyObject {
}
