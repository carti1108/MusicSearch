//
//  MusicDiggingRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import RIBs

final class MusicDiggingRouter: ViewableRouter<MusicDiggingInteractable, MusicDiggingViewControllable>, MusicDiggingRouting {
	override init(interactor: MusicDiggingInteractable, viewController: MusicDiggingViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
