//
//  TrackSearchBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

protocol DiggingDependency: Dependency {
	var searchTracksUseCase: SearchTracksUseCase { get }
	var fetchTracksByTagUseCase: FetchTracksByTagUseCase { get }
	var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

final class DiggingComponent: Component<DiggingDependency>, DiggingDependency {
	var searchTracksUseCase: SearchTracksUseCase {
		self.dependency.searchTracksUseCase
	}

	var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
		self.dependency.fetchTracksByTagUseCase
	}

	var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase {
		self.dependency.fetchSimilarTrackUseCase
	}

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}
}

protocol TrackSearchBuildable: Buildable {
	func build(
		withListener listener: TrackSearchListener,
		navigationController: UINavigationController
	) -> TrackSearchRouting
}

final class TrackSearchBuilder: Builder<DiggingDependency>, TrackSearchBuildable {
	override init(dependency: DiggingDependency) {
		super.init(dependency: dependency)
	}

	func build(
		withListener listener: TrackSearchListener,
		navigationController: UINavigationController
	) -> TrackSearchRouting {
		MainActor.assumeIsolated {
			let component = DiggingComponent(dependency: self.dependency)
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
}
