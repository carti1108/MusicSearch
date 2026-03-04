//
//  HomeRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import RIBs

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable>, HomeRouting {
	override init(interactor: HomeInteractable, viewController: HomeViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
