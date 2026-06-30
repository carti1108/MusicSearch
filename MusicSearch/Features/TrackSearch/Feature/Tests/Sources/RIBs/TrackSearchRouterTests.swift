//
//  TrackSearchRouterTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import MSDomain

import Foundation
import Testing
import UIKit
import MicroRIBs
@testable import FeatureTrackSearch
@testable import FeatureTrackSearchTesting

@MainActor
struct TrackSearchRouterTests {

	@Test("attachMusicDigging 호출 시 child router를 붙이고 화면을 push하는가")
	func attachMusicDiggingPushesChildViewController() {
		// Given
		let presenter = RouterTrackSearchPresentableSpy()
		let useCase = RouterMockSearchTracksUseCase()
		let interactor = TrackSearchInteractor(
			presenter: presenter,
			searchTracksUseCase: useCase
		)
		let rootViewController = RouterMockTrackSearchViewController()
		let navigationController = UINavigationController()
		let musicDiggingBuilder = MusicDiggingBuilderSpy()
		let childRouter = MusicDiggingRoutingSpy(
			interactor: MockMusicDiggingInteractable(),
			viewController: MockMusicDiggingViewController()
		)
		musicDiggingBuilder.buildHandler = { _, _ in childRouter }
		let router = TrackSearchRouter(
			interactor: interactor,
			viewController: rootViewController,
			navigationController: navigationController,
			musicDiggingBuilder: musicDiggingBuilder
		)
		router.load()

		let seedTrack = Track(title: "Starlight", artist: "Muse", imageURL: nil)

		// When
		router.attachMusicDigging(seedTrack: seedTrack)

		// Then
		#expect(router.children.count == 1)
		#expect(musicDiggingBuilder.buildCallCount == 1)
		#expect(router.children.first === childRouter)
		#expect(musicDiggingBuilder.receivedSeedTrack?.title == "Starlight")
		#expect(musicDiggingBuilder.receivedListener === interactor)
		#expect(navigationController.viewControllers.count == 2)
		#expect(navigationController.topViewController === childRouter.viewControllable.uiViewController)
		#expect(childRouter.interactable.isActive == true)
	}

	@Test("내비게이션 pop 이후 child router를 detach하는가")
	func navigationPopDetachesChildRouter() {
		// Given
		let presenter = RouterTrackSearchPresentableSpy()
		let useCase = RouterMockSearchTracksUseCase()
		let interactor = TrackSearchInteractor(
			presenter: presenter,
			searchTracksUseCase: useCase
		)
		let rootViewController = RouterMockTrackSearchViewController()
		let navigationController = UINavigationController()
		let musicDiggingBuilder = MusicDiggingBuilderSpy()
		let childRouter = MusicDiggingRoutingSpy(
			interactor: MockMusicDiggingInteractable(),
			viewController: MockMusicDiggingViewController()
		)
		musicDiggingBuilder.buildHandler = { _, _ in childRouter }
		let router = TrackSearchRouter(
			interactor: interactor,
			viewController: rootViewController,
			navigationController: navigationController,
			musicDiggingBuilder: musicDiggingBuilder
		)
		router.load()
		router.attachMusicDigging(seedTrack: Track(title: "Madness", artist: "Muse", imageURL: nil))

		// When
		_ = navigationController.popViewController(animated: false)
		navigationController.delegate?.navigationController?(
			navigationController,
			didShow: rootViewController,
			animated: false
		)

		// Then
		#expect(router.children.isEmpty)
		#expect(musicDiggingBuilder.buildCallCount == 1)
		#expect(childRouter.interactable.isActive == false)
	}
}
