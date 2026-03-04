//
//  TrackSearchBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import RIBs

protocol DiggingDependency: Dependency {
	var searchTracksUseCase: SearchTracksUseCase { get }
	var fetchTracksByTagUseCase: FetchTracksByTagUseCase { get }
	var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase { get }
}

protocol TrackSearchBuildable: Buildable {
	func build(navigationController: UINavigationController) -> TrackSearchRouting
}

final class TrackSearchBuilder: Builder<DiggingDependency>, TrackSearchBuildable {
	override init(dependency: DiggingDependency) {
		super.init(dependency: dependency)
	}

	func build(navigationController: UINavigationController) -> TrackSearchRouting {
		MainActor.assumeIsolated {
			let viewController = TrackSearchViewController()
			let interactor = TrackSearchInteractor(
				presenter: viewController,
				searchTracksUseCase: self.dependency.searchTracksUseCase
			)
			let musicDiggingBuilder = MusicDiggingBuilder(dependency: self.dependency)
			return TrackSearchRouter(
				interactor: interactor,
				viewController: viewController,
				navigationController: navigationController,
				musicDiggingBuilder: musicDiggingBuilder
			)
		}
	}
}
