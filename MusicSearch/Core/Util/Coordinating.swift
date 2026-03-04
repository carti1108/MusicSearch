//
//  Coordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit

@MainActor
protocol Coordinating: AnyObject {
	var navigationController: UINavigationController { get set }
	var childCoordinators: [Coordinating] { get set }
	func start()
}

@MainActor
class Coordinator: Coordinating {
	var navigationController: UINavigationController
	var childCoordinators: [Coordinating] = []

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func start() {
		fatalError("start() must be overridden by subclasses")
	}

	func addChild(_ coordinator: Coordinating) {
		self.childCoordinators.append(coordinator)
	}

	func removeChild(_ coordinator: Coordinating) {
		self.childCoordinators.removeAll { $0 === coordinator }
	}
}
