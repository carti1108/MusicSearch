//
//  MusicDiggingRouterTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import MSDomain

import Testing
import UIKit
import MicroRIBs
@testable import FeatureMusicDigging
@testable import FeatureMusicDiggingTesting

@MainActor
struct MusicDiggingRouterTests {

	@Test("초기화 시 interactor router가 연결되는가")
	func initSetsInteractorRouter() {
		// Given
		let interactor = MockMusicDiggingInteractableForRouter()
		let viewController = MockMusicDiggingViewControllerForRouter()

		// When
		let router = MusicDiggingRouter(interactor: interactor, viewController: viewController)

		// Then
		#expect(interactor.router === router)
	}
}
