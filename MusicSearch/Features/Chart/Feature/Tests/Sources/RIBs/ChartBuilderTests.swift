//
//  ChartBuilderTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import MSDomain

import Foundation
import Testing
import UIKit
@testable import FeatureChart
import FeatureChartTesting

@MainActor
struct ChartBuilderTests {

	@Test("build 시 listener와 presenter가 정상 연결되고 의존성이 주입되는가")
	func buildWiresListenerPresenterAndDependencies() async {
		// Given
		let fetchChartTopTracksUseCase = MockFetchChartTopTracksUseCaseForBuilder()
		let dependency = MockChartDependency(
			fetchChartTopTracksUseCase: fetchChartTopTracksUseCase,
			fetchChartTopArtistsUseCase: MockFetchChartTopArtistsUseCaseForBuilder(),
			fetchMusicAppDeepLinkUseCase: MockFetchMusicAppDeepLinkUseCaseForChartBuilder(),
			urlOpener: MockURLOpener()
		)
		let builder = ChartBuilder(dependency: dependency)
		let listener = MockChartListener()

		// When
		let routing = builder.build(withListener: listener)

		// Then
		#expect(routing is ChartRouter)
		guard let router = routing as? ChartRouter else {
			Issue.record("ChartRouter 타입이 반환되어야 합니다.")
			return
		}
		guard let interactor = router.interactor as? ChartInteractor else {
			Issue.record("ChartInteractor가 조립되어야 합니다.")
			return
		}
		guard let viewController = router.viewControllable as? ChartViewController else {
			Issue.record("ChartViewController가 조립되어야 합니다.")
			return
		}

		#expect(interactor.listener === listener)
		#expect(viewController.listener === interactor)
	}
}
