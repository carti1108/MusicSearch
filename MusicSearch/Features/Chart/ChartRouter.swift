//
//  ChartRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs

@MainActor
protocol ChartInteractable: Interactable {
	var router: ChartRouting? { get set }
	var listener: ChartListener? { get set }
}

protocol ChartViewControllable: ViewControllable {}

final class ChartRouter: ViewableRouter<ChartInteractable, ChartViewControllable>, ChartRouting {
	override init(interactor: ChartInteractable, viewController: ChartViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
