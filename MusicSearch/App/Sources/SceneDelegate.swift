//
//  SceneDelegate.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import UIKit
import RIBs

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?
	private var launchRouter: LaunchRouting?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		let window = UIWindow(windowScene: windowScene)
		let appComponent = AppComponent()
		let rootBuilder = RootBuilder(dependency: appComponent)
		let launchRouter = rootBuilder.build()
		launchRouter.launch(from: window)

		self.launchRouter = launchRouter
		self.window = window
	}
}
