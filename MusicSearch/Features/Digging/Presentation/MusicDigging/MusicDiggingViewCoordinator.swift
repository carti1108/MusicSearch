//
//  MusicDiggingViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit

@MainActor
protocol MusicDiggingViewCoordinatorAction: AnyObject {
	func didTapSeedTrack(_ track: Track)
}

final class MusicDiggingViewCoordinator<T: DiggingDependency>: Coordinator, MusicDiggingViewCoordinatorAction, MusicAppRouting {
	private let component: DiggingComponent<T>
	private let seedTrack: Track
	private var viewModel: MusicDiggingViewModel?

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.component.fetchMusicAppDeepLinkUseCase
	}

	init(
		navigationController: UINavigationController,
		component: DiggingComponent<T>,
		seedTrack: Track
	) {
		self.component = component
		self.seedTrack = seedTrack
		super.init(navigationController: navigationController)
	}

	@MainActor
	override func start() {
		let diggingVC = MusicDiggingViewController()
		let viewModel = self.component.makeMusicDiggingViewModel(
			seedTrack: self.seedTrack,
			view: diggingVC
		)
		viewModel.coordinator = self
		self.viewModel = viewModel
		self.navigationController.pushViewController(diggingVC, animated: true)
	}

	func didTapSeedTrack(_ track: Track) {
		self.openMusicApp(for: track)
	}
}
