//
//  FeatureAddArchiveInterface.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain
import TrackSearchDomain
import FeatureArchiveTrackSearchInterface

@MainActor
public protocol AddArchiveDependency: Dependency {
	var archiveRepository: ArchiveRepository { get }
	var searchTracksUseCase: SearchTracksUseCase { get }
	var archiveTrackSearchBuilder: ArchiveTrackSearchBuildable { get }
}

public protocol AddArchiveBuildable: Buildable {
	func build(withListener listener: AddArchiveListener, editTrack: ArchivedTrack?) -> AddArchiveRouting
}

public protocol AddArchiveRouting: ViewableRouting {
	func routeToArchiveTrackSearch()
	func detachArchiveTrackSearch()
}

@MainActor
public protocol AddArchiveListener: AnyObject {
	func didCloseAddArchive()
}
