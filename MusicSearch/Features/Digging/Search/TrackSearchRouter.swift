//
//  TrackSearchRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

@MainActor
protocol TrackSearchInteractable: Interactable, MusicDiggingListener {
	var router: TrackSearchRouting? { get set }
	var listener: TrackSearchListener? { get set }
}

@MainActor
protocol TrackSearchViewControllable: ViewControllable {}

@MainActor
final class TrackSearchRouter: ViewableRouter<TrackSearchInteractable, TrackSearchViewControllable>, TrackSearchRouting {
	private final class NavigationDelegateProxy: NSObject, UINavigationControllerDelegate {
		weak var router: TrackSearchRouter?

		init(router: TrackSearchRouter) {
			self.router = router
		}

		func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
			self.router?.detachPoppedChildrenIfNeeded()
		}
	}

	private let navigationController: UINavigationController
	private let musicDiggingBuilder: MusicDiggingBuildable
	private lazy var navigationDelegateProxy: NavigationDelegateProxy = .init(router: self)

	private var childRoutersByViewControllerID: [ObjectIdentifier: Routing] = [:]

	init(
		interactor: TrackSearchInteractable,
		viewController: TrackSearchViewControllable,
		navigationController: UINavigationController,
		musicDiggingBuilder: MusicDiggingBuildable
	) {
		self.navigationController = navigationController
		self.musicDiggingBuilder = musicDiggingBuilder
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}

	override func didLoad() {
		super.didLoad()
		self.navigationController.setViewControllers([self.viewControllable.uiViewController], animated: false)
		self.navigationController.delegate = self.navigationDelegateProxy
	}

	func attachMusicDigging(seedTrack: Track) {
		let musicDiggingRouter = self.musicDiggingBuilder.build(
			withListener: self.interactor,
			seedTrack: seedTrack
		)
		self.attachChild(musicDiggingRouter)

		let viewController = musicDiggingRouter.viewControllable.uiViewController
		self.childRoutersByViewControllerID[ObjectIdentifier(viewController)] = musicDiggingRouter
		self.navigationController.pushViewController(viewController, animated: true)
	}

	private func detachPoppedChildrenIfNeeded() {
		let visibleViewControllerIDs = Set(self.navigationController.viewControllers.map { ObjectIdentifier($0) })
		let poppedIDs = self.childRoutersByViewControllerID.keys.filter { !visibleViewControllerIDs.contains($0) }

		for poppedID in poppedIDs {
			guard let childRouter = self.childRoutersByViewControllerID[poppedID] else { continue }
			self.detachChild(childRouter)
			self.childRoutersByViewControllerID[poppedID] = nil
		}
	}
}
