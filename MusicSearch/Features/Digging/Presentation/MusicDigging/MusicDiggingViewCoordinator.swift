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
		let diggingVC = self.component.makeMusicDiggingViewController(seedTrack: self.seedTrack)
		self.navigationController.pushViewController(diggingVC, animated: true)
	}
}
