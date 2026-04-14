//
//  RootRouterTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Testing
import UIKit
import MicroRIBs
@testable import MusicSearch

@MainActor
struct RootRouterTests {

	@Test("didLoad 시 세 개의 탭 RIB를 attach하고 탭바를 구성하는가")
	func didLoadAttachesChildRIBsAndSetsTabs() {
		// Given
		let interactor = RootInteractor(presenter: RootRouterPresentableSpy())
		let viewController = RootViewControllableSpy()
		let weatherRecommendationBuilder = WeatherRecommendationBuilderSpy()
		let trackSearchBuilder = TrackSearchBuilderSpy()
		let chartBuilder = ChartBuilderSpy()
		let weatherRouter = RootWeatherRecommendationRoutingSpy(
			interactor: MockRootWeatherRecommendationInteractable(),
			viewController: MockRootWeatherRecommendationViewController()
		)
		weatherRecommendationBuilder.buildHandler = { _ in weatherRouter }
		let trackSearchRouter = RootTrackSearchRoutingSpy(
			interactor: MockRootTrackSearchInteractable(),
			viewController: MockRootTrackSearchViewController()
		)
		trackSearchBuilder.buildHandler = { _, _ in trackSearchRouter }
		let chartRouter = RootChartRoutingSpy(
			interactor: MockRootChartInteractable(),
			viewController: MockRootChartViewController()
		)
		chartBuilder.buildHandler = { _ in chartRouter }
		let router = RootRouter(
			interactor: interactor,
			viewController: viewController,
			weatherRecommendationBuilder: weatherRecommendationBuilder,
			trackSearchBuilder: trackSearchBuilder,
			chartBuilder: chartBuilder
		)

		// When
		router.load()

		// Then
		#expect(router.children.count == 3)
		#expect(weatherRecommendationBuilder.buildCallCount == 1)
		#expect(trackSearchBuilder.buildCallCount == 1)
		#expect(chartBuilder.buildCallCount == 1)
		#expect(weatherRecommendationBuilder.receivedListener === interactor)
		#expect(trackSearchBuilder.receivedListener === interactor)
		#expect(chartBuilder.receivedListener === interactor)
		#expect(trackSearchBuilder.receivedNavigationController != nil)
		#expect(viewController.capturedTabs.count == 3)
		#expect(viewController.capturedTabs.compactMap { $0.tabBarItem.title } == ["Weather", "Search", "Chart"])
	}
}
