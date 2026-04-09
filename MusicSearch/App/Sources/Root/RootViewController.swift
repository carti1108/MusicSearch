//
//  RootViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

final class RootViewController: UITabBarController, RootPresentable, RootViewControllable {
	weak var listener: RootPresentableListener?

	func setTabs(_ viewControllers: [UIViewController]) {
		self.viewControllers = viewControllers
	}
}
