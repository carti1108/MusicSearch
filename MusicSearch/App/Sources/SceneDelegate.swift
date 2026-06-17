//
//  SceneDelegate.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import UIKit
import MicroRIBs

@MainActor
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

	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		guard let url = URLContexts.first?.url else { return }
		// Forward to SpotifyAuthManager
		// Assuming SpotifyAuthManager is accessible here or we can use NSClassFromString since it's in NetworkLayer
		// Alternatively, we can use NotificationCenter, but since it's just a singleton:
		// We need to import the module where SpotifyAuthManager is defined. It's in MusicSearch app target or NetworkLayer?
		// Wait, I created it in Core/Data/Network/, but what target is it? Probably MSData.
		// Since SceneDelegate is in App, we can import MSData.
		NotificationCenter.default.post(name: NSNotification.Name("SpotifyAuthCallback"), object: url)
	}
}
