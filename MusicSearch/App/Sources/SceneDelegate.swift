//
//  SceneDelegate.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	private var appRoot: AppRoot?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		self.appRoot = AppRoot()

		let window = UIWindow(windowScene: windowScene)
		window.rootViewController = appRoot?.makeRootTabBarController()
		window.makeKeyAndVisible()

		self.window = window
	}
}
