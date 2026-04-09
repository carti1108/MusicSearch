//
//  MusicDiggingRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs

protocol MusicDiggingInteractable: Interactable {
	var router: MusicDiggingRouting? { get set }
	var listener: MusicDiggingListener? { get set }
}

protocol MusicDiggingViewControllable: ViewControllable {}

final class MusicDiggingRouter: ViewableRouter<MusicDiggingInteractable, MusicDiggingViewControllable>, MusicDiggingRouting {
	override init(interactor: MusicDiggingInteractable, viewController: MusicDiggingViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
