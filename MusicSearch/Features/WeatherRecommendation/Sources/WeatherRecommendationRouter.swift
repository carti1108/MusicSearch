//
//  WeatherRecommendationRouter.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs
import FeatureWeatherRecommendationInterface

@MainActor
protocol WeatherRecommendationInteractable: Interactable {
	var router: WeatherRecommendationRouting? { get set }
	var listener: WeatherRecommendationListener? { get set }
}

@MainActor
protocol WeatherRecommendationViewControllable: ViewControllable {}

@MainActor
final class WeatherRecommendationRouter: ViewableRouter<WeatherRecommendationInteractable, WeatherRecommendationViewControllable>, WeatherRecommendationRouting {
	override init(interactor: WeatherRecommendationInteractable, viewController: WeatherRecommendationViewControllable) {
		super.init(interactor: interactor, viewController: viewController)
		interactor.router = self
	}
}
