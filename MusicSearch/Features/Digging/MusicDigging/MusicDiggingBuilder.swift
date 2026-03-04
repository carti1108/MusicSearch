//
//  MusicDiggingBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import RIBs

protocol MusicDiggingBuildable: Buildable {
	func build(seedTrack: Track) -> MusicDiggingRouting
}

final class MusicDiggingBuilder: Builder<DiggingDependency>, MusicDiggingBuildable {
	override init(dependency: DiggingDependency) {
		super.init(dependency: dependency)
	}

	func build(seedTrack: Track) -> MusicDiggingRouting {
		MainActor.assumeIsolated {
			let viewController = MusicDiggingViewController()
			let interactor = MusicDiggingInteractor(
				seedTrack: seedTrack,
				presenter: viewController,
				fetchSimilarTracksUseCase: self.dependency.fetchSimilarTrackUseCase
			)
			return MusicDiggingRouter(interactor: interactor, viewController: viewController)
		}
	}
}
