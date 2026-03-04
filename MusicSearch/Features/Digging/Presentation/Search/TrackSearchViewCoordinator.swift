//
//  TrackSearchViewCoordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/12/25.
//

import UIKit

final class TrackSearchViewCoordinator<T: DiggingDependency>: Coordinator, TrackSearchViewCoordinatorAction {
	private let component: DiggingComponent<T>

	init(
		navigationController: UINavigationController,
		component: DiggingComponent<T>
	) {
		self.component = component
		super.init(navigationController: navigationController)
	}

	override func start() {
		let vc = self.component.makeTrackSearchViewController(coordinator: self)
		self.navigationController.setViewControllers([vc], animated: false)
	}

	func didSelect(_ track: Track) {
		let diggingCoordinator = MusicDiggingViewCoordinator(
			navigationController: self.navigationController,
			component: self.component,
			seedTrack: track
		)

		diggingCoordinator.start()
	}
}
