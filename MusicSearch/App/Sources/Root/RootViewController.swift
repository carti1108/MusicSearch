//
//  RootViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

@MainActor
final class RootViewController: UITabBarController, RootPresentable, RootViewControllable {
	weak var listener: RootPresentableListener?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureAppearance()
	}

	func setTabs(_ viewControllers: [UIViewController]) {
		self.viewControllers = viewControllers
	}

	private func configureAppearance() {
		let appearance = UITabBarAppearance()
		appearance.configureWithTransparentBackground()
		appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
		appearance.backgroundColor = UIColor.black.withAlphaComponent(0.55)
		appearance.shadowColor = UIColor.white.withAlphaComponent(0.06)

		let normalColor = UIColor.white.withAlphaComponent(0.6)
		let selectedColor = UIColor(red: 0.49, green: 0.87, blue: 0.96, alpha: 1.0)
		[appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance].forEach {
			$0.normal.iconColor = normalColor
			$0.normal.titleTextAttributes = [.foregroundColor: normalColor]
			$0.selected.iconColor = selectedColor
			$0.selected.titleTextAttributes = [.foregroundColor: selectedColor]
		}

		self.tabBar.standardAppearance = appearance
		self.tabBar.scrollEdgeAppearance = appearance
		self.tabBar.tintColor = selectedColor
		self.tabBar.unselectedItemTintColor = normalColor
		self.tabBar.isTranslucent = true
		self.tabBar.layer.cornerRadius = 26
		self.tabBar.layer.masksToBounds = true
	}
}
