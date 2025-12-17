//
//  Coordinator.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
	var navigationController: UINavigationController { get set }
	var childCoordinators: [Coordinator] { get set }
	func start()
}
