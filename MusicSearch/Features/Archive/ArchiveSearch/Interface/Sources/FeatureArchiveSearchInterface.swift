//
//  FeatureArchiveSearchInterface.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import MicroRIBs

public protocol ArchiveSearchBuildable: Buildable {
    func build(withListener listener: ArchiveSearchListener) -> ArchiveSearchRouting
}

public protocol ArchiveSearchRouting: ViewableRouting {
}

@MainActor
public protocol ArchiveSearchListener: AnyObject {
    func archiveSearchDidTapClose()
}
