//
//  TrendRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import RIBs

protocol TrendInteractable: Interactable {
	var router: TrendRouting? { get set }
	var listener: TrendListener? { get set }
}

protocol TrendViewControllable: ViewControllable {}

final class TrendRouter: ViewableRouter<TrendInteractable, TrendViewControllable>, TrendRouting {
	override init(interactor: TrendInteractable, viewController: TrendViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
