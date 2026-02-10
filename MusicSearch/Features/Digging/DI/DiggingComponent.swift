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
	func makeTrackSearchViewModel() -> TrackSearchViewModel {
		TrackSearchViewModel(searchTracksUseCase: self.dependency.searchTracksUseCase)
	}

	@MainActor
	func makeMusicDiggingViewModel(seedTrack: Track, fetchSimilarTracksUseCase: FetchSimilarTracksUseCase) -> MusicDiggingViewModel {
		MusicDiggingViewModel(seedTrack: seedTrack, fetchSimilarTracksUseCase: fetchSimilarTracksUseCase)
	}

	@MainActor
	func makeTrackSearchCoordinator(navigationController: UINavigationController) -> TrackSearchViewCoordinator<T> {
		return TrackSearchViewCoordinator(
			navigationController: navigationController,
			component: self
		)
	}

	@MainActor
	func makeTrackSearchViewController(coordinator: TrackSearchViewCoordinatorAction) -> UIViewController {
		let vm = self.makeTrackSearchViewModel()
		vm.coordinator = coordinator
		return TrackSearchViewController(viewModel: vm)
	}

	@MainActor
	func makeMusicDiggingViewController(seedTrack: Track) -> MusicDiggingViewController {
		let viewModel = self.makeMusicDiggingViewModel(seedTrack: seedTrack, fetchSimilarTracksUseCase: self.dependency.fetchSimilarTrackUseCase)
		return MusicDiggingViewController(viewModel: viewModel)
	}
}
