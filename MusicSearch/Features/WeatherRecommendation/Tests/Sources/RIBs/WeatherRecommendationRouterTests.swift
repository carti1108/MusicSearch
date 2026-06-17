import MSDomain
//
//  WeatherRecommendationRouterTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Testing
import UIKit
import MicroRIBs
@testable import FeatureWeatherRecommendation
@testable import FeatureWeatherRecommendationTesting

@MainActor
struct WeatherRecommendationRouterTests {

	@Test("초기화 시 interactor router가 연결되는가")
	func initSetsInteractorRouter() {
		// Given
		let interactor = MockWeatherRecommendationInteractableForRouter()
		let viewController = MockWeatherRecommendationViewControllerForRouter()

		// When
		let router = WeatherRecommendationRouter(interactor: interactor, viewController: viewController)

		// Then
		#expect(interactor.router === router)
	}
}
