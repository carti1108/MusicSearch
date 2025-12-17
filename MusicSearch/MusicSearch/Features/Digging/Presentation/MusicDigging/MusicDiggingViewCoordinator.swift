//
//  MusicDiggingViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit

final class MusicDiggingViewCoordinator<T: DiggingDependency>: Coordinator {

	var navigationController: UINavigationController
	var childCoordinators: [Coordinator] = []

	private let component: DiggingComponent<T>
	private let seedTrack: Track

	init(
		navigationController: UINavigationController,
		component: DiggingComponent<T>,
		seedTrack: Track
	) {
		self.navigationController = navigationController
		self.component = component
		self.seedTrack = seedTrack
	}

	@MainActor
	func start() {
		let diggingVC = self.component.makeMusicDiggingViewController(seedTrack: self.seedTrack)
		self.navigationController.pushViewController(diggingVC, animated: true)
	}
}
