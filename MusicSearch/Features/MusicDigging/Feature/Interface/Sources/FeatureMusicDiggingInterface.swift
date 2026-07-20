//
//  FeatureMusicDiggingInterface.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import MicroRIBs
import MSDomain
import MSUtil
import MusicDiggingDomain

@MainActor
public protocol MusicDiggingBuildable: Buildable {
	func build(
		withListener listener: MusicDiggingListener,
		seedTrack: Track
	) -> MusicDiggingRouting
}

@MainActor
public protocol MusicDiggingRouting: ViewableRouting {}

@MainActor
public protocol MusicDiggingListener: AnyObject {}

@MainActor
public protocol MusicDiggingDependency: Dependency {
	var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase { get }
	var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase { get }
	var urlOpener: URLOpening { get }
}
