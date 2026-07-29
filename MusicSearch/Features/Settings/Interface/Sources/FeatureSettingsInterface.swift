//
//  FeatureSettingsInterface.swift
//  MusicSearch
//
//  Created by Kiseok on 6/17/26.
//

import MicroRIBs

@MainActor
public protocol SettingsBuildable: Buildable {
    func build(withListener listener: SettingsListener) -> SettingsRouting
}

@MainActor
public protocol SettingsRouting: ViewableRouting {
}

@MainActor
public protocol SettingsListener: AnyObject {
}
