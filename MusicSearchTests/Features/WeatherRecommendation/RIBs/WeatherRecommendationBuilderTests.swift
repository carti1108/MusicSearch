//
//  WeatherRecommendationBuilderTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Foundation
import Testing
import UIKit
@testable import MusicSearch

@MainActor
struct WeatherRecommendationBuilderTests {

	@Test("build 시 listener와 presenter가 정상 연결되고 의존성이 주입되는가")
	func buildWiresListenerPresenterAndDependencies() async {
		// Given
		let fetchMusicForWeatherUseCase = MockFetchMusicForWeatherUseCase()
		let fetchMusicAppDeepLinkUseCase = MockFetchMusicAppDeepLinkUseCase()
		let dependency = MockWeatherRecommendationDependency(
			fetchMusicForWeatherUseCase: fetchMusicForWeatherUseCase,
			fetchMusicAppDeepLinkUseCase: fetchMusicAppDeepLinkUseCase
		)
		let builder = WeatherRecommendationBuilder(dependency: dependency)
		let listener = MockWeatherRecommendationListener()

		// When
		let routing = builder.build(withListener: listener)

		// Then
		#expect(routing is WeatherRecommendationRouter)
		guard let router = routing as? WeatherRecommendationRouter else {
			Issue.record("WeatherRecommendationRouter 타입이 반환되어야 합니다.")
			return
		}
		guard let interactor = router.interactor as? WeatherRecommendationInteractor else {
			Issue.record("WeatherRecommendationInteractor가 조립되어야 합니다.")
			return
		}
		guard let viewController = router.viewControllable as? WeatherRecommendationViewController else {
			Issue.record("WeatherRecommendationViewController가 조립되어야 합니다.")
			return
		}

		#expect(interactor.listener === listener)
		#expect(viewController.listener === interactor)
	}
}
