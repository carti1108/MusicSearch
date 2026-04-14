//
//  RootBuilderTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Foundation
import Testing
import UIKit
@testable import MusicSearch

@MainActor
struct RootBuilderTests {

	@Test("build 시 RootRouter, RootInteractor, RootViewController가 정상 조립되는가")
	func buildAssemblesRootRIB() {
		// Given
		let dependency = MockRootDependency(
			fetchMusicForWeatherUseCase: RootMockFetchMusicForWeatherUseCase(),
			fetchMusicAppDeepLinkUseCase: RootMockFetchMusicAppDeepLinkUseCase(),
			searchTracksUseCase: RootMockSearchTracksUseCase(),
			fetchTracksByTagUseCase: RootMockFetchTracksByTagUseCase(),
			fetchSimilarTrackUseCase: RootMockFetchSimilarTracksUseCase(),
			fetchChartTopTracksUseCase: RootMockFetchChartTopTracksUseCase(),
			fetchChartTopArtistsUseCase: RootMockFetchChartTopArtistsUseCase()
		)
		let builder = RootBuilder(dependency: dependency)

		// When
		let routing = builder.build()

		// Then
		#expect(routing is RootRouter)
		guard let router = routing as? RootRouter else {
			Issue.record("RootRouter 타입이 반환되어야 합니다.")
			return
		}
		guard let interactor = router.interactor as? RootInteractor else {
			Issue.record("RootInteractor가 조립되어야 합니다.")
			return
		}
		guard let viewController = router.viewControllable as? RootViewController else {
			Issue.record("RootViewController가 조립되어야 합니다.")
			return
		}

		#expect(interactor.router === router)
		#expect(viewController.listener === interactor)
	}
}
