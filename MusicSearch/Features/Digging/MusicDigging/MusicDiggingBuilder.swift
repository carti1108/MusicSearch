//
//  MusicDiggingBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs

protocol MusicDiggingDependency: Dependency {
	var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

protocol MusicDiggingBuildable: Buildable {
	func build(
		withListener listener: MusicDiggingListener,
		seedTrack: Track
	) -> MusicDiggingRouting
}

final class MusicDiggingBuilder: Builder<MusicDiggingDependency>, MusicDiggingBuildable {
	override init(dependency: MusicDiggingDependency) {
		super.init(dependency: dependency)
	}

	func build(
		withListener listener: MusicDiggingListener,
		seedTrack: Track
	) -> MusicDiggingRouting {
		MainActor.assumeIsolated {
			let viewController = MusicDiggingViewController()
			let interactor = MusicDiggingInteractor(
				seedTrack: seedTrack,
				presenter: viewController,
				fetchSimilarTracksUseCase: self.dependency.fetchSimilarTrackUseCase,
				fetchMusicAppDeepLinkUseCase: self.dependency.fetchMusicAppDeepLinkUseCase
			)
			interactor.listener = listener
			return MusicDiggingRouter(interactor: interactor, viewController: viewController)
		}
	}
}
