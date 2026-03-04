//
//  MusicDiggingViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit

final class MusicDiggingViewCoordinator<T: DiggingDependency>: Coordinator {
	private let component: DiggingComponent<T>
	private let seedTrack: Track
	private var viewModel: MusicDiggingViewModel?

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
		self.viewModel = viewModel
		self.navigationController.pushViewController(diggingVC, animated: true)
	}
}
