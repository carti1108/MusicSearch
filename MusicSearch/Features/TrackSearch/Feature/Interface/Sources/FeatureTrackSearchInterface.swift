import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
import TrackSearchDomain
import MusicDiggingDomain
import FeatureMusicDiggingInterface

@MainActor
public protocol TrackSearchBuildable: Buildable {
	func build(
		withListener listener: TrackSearchListener,
		navigationController: UINavigationController
	) -> TrackSearchRouting
}

@MainActor
public protocol TrackSearchRouting: ViewableRouting {
	func attachMusicDigging(seedTrack: Track)
}

@MainActor
public protocol TrackSearchListener: AnyObject {}

@MainActor
public protocol TrackSearchDependency: Dependency {
	var searchTracksUseCase: SearchTracksUseCase { get }
	var fetchTracksByTagUseCase: FetchTracksByTagUseCase { get }
	var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase { get }
	var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase { get }
	var urlOpener: URLOpening { get }
	var musicDiggingBuilder: MusicDiggingBuildable { get }
}
