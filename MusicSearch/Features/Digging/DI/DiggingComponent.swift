//
//  DiggingComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import UIKit

final class DiggingComponent<T: DiggingDependency>: Component {

	typealias DependencyType = T

	private let dependency: T

	init(dependency: T) {
		self.dependency = dependency
	}

	@MainActor
	func makeTrackSearchViewModel(view: TrackSearchViewable) -> TrackSearchViewModel {
		TrackSearchViewModel(
			view: view,
			searchTracksUseCase: self.dependency.searchTracksUseCase
		)
	}

	@MainActor
	func makeMusicDiggingViewModel(seedTrack: Track, view: MusicDiggingViewable) -> MusicDiggingViewModel {
		MusicDiggingViewModel(
			seedTrack: seedTrack,
			view: view,
			fetchSimilarTracksUseCase: self.dependency.fetchSimilarTrackUseCase
		)
	}

	@MainActor
	func makeTrackSearchCoordinator(navigationController: UINavigationController) -> TrackSearchViewCoordinator<T> {
		return TrackSearchViewCoordinator(
			navigationController: navigationController,
			component: self
		)
	}
}
