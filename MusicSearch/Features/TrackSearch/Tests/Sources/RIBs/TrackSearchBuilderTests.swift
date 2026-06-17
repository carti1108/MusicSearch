import MSDomain
//
//  TrackSearchBuilderTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Foundation
import Testing
import UIKit
@testable import FeatureTrackSearch
@testable import FeatureTrackSearchTesting

@MainActor
struct TrackSearchBuilderTests {

	@Test("build 시 listener와 presenter가 정상 연결되고 내비게이션 루트가 설정되는가")
	func buildWiresListenerPresenterAndNavigationRoot() {
		// Given
		let dependency = MockTrackSearchDependency(
			searchTracksUseCase: MockSearchTracksUseCaseForBuilder(),
			fetchTracksByTagUseCase: MockFetchTracksByTagUseCaseForTrackSearchBuilder(),
			fetchSimilarTracksUseCase: MockFetchSimilarTracksUseCaseForTrackSearchBuilder(),
			fetchMusicAppDeepLinkUseCase: MockFetchMusicAppDeepLinkUseCaseForTrackSearchBuilder()
		)
		let builder = TrackSearchBuilder(dependency: dependency)
		let navigationController = UINavigationController()
		let listener = MockTrackSearchListener()

		// When
		let routing = builder.build(
			withListener: listener,
			navigationController: navigationController
		)

		// Then
		#expect(routing is TrackSearchRouter)
		guard let router = routing as? TrackSearchRouter else {
			Issue.record("TrackSearchRouter 타입이 반환되어야 합니다.")
			return
		}
		guard let interactor = router.interactor as? TrackSearchInteractor else {
			Issue.record("TrackSearchInteractor가 조립되어야 합니다.")
			return
		}
		guard let viewController = router.viewControllable as? TrackSearchViewController else {
			Issue.record("TrackSearchViewController가 조립되어야 합니다.")
			return
		}

		#expect(interactor.listener === listener)
		#expect(viewController.listener === interactor)

		router.load()

		#expect(navigationController.viewControllers.first === viewController)
	}
}
