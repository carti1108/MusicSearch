//
//  TrackSearchBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs
import FeatureTrackSearchInterface
import FeatureMusicDiggingInterface
import FeatureMusicDigging
import MSDomain
import MSUtil



@MainActor
final class TrackSearchComponent: Component<TrackSearchDependency>, TrackSearchDependency, MusicDiggingDependency {
	var searchTracksUseCase: SearchTracksUseCase {
		self.dependency.searchTracksUseCase
	}
	
	var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
		self.dependency.fetchTracksByTagUseCase
	}
	
	var fetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
		self.dependency.fetchSimilarTracksUseCase
	}
	
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}
	
	var urlOpener: URLOpening {
		self.dependency.urlOpener
	}
}



@MainActor
public final class TrackSearchBuilder: Builder<TrackSearchDependency>, TrackSearchBuildable {
	public override init(dependency: TrackSearchDependency) {
		super.init(dependency: dependency)
	}
	
	public func build(
		withListener listener: TrackSearchListener,
		navigationController: UINavigationController
	) -> TrackSearchRouting {
		let component = TrackSearchComponent(dependency: self.dependency)
		let viewController = TrackSearchViewController()
		let interactor = TrackSearchInteractor(
			presenter: viewController,
			searchTracksUseCase: component.searchTracksUseCase
		)
		interactor.listener = listener
		
		let musicDiggingBuilder = MusicDiggingBuilder(dependency: component)
		return TrackSearchRouter(
			interactor: interactor,
			viewController: viewController,
			navigationController: navigationController,
			musicDiggingBuilder: musicDiggingBuilder
		)
	}
}
