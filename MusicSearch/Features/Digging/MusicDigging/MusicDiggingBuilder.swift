//
//  MusicDiggingBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs

protocol MusicDiggingBuildable: Buildable {
	func build(
		withListener listener: MusicDiggingListener,
		seedTrack: Track
	) -> MusicDiggingRouting
}

final class MusicDiggingBuilder: Builder<DiggingDependency>, MusicDiggingBuildable {
	override init(dependency: DiggingDependency) {
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
				fetchSimilarTracksUseCase: self.dependency.fetchSimilarTrackUseCase
			)
			interactor.listener = listener
			return MusicDiggingRouter(interactor: interactor, viewController: viewController)
		}
	}
}
