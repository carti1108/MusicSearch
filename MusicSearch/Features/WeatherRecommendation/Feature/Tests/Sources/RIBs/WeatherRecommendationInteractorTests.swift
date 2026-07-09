//
//  WeatherRecommendationInteractorTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import MSDomain

import Foundation
import Testing
@testable import FeatureWeatherRecommendation
@testable import FeatureWeatherRecommendationTesting

@MainActor
struct WeatherRecommendationInteractorTests {

	@Test("viewDidLoad 호출 시 날씨 추천을 로드하고 presenter에 반영하는가")
	func viewDidLoadLoadsWeatherRecommendation() async {
		// Given
		let presenter = WeatherRecommendationPresentableSpy()
		let fetchMusicForWeatherUseCase = MockFetchMusicForWeatherUseCaseForInteractor()
		let interactor = WeatherRecommendationInteractor(
			presenter: presenter,
			fetchMusicForWeatherUseCase: fetchMusicForWeatherUseCase,
			fetchTrackDeepLinkUseCase: MockFetchTrackDeepLinkUseCaseForWeatherRecommendationInteractor(),
			urlOpener: MockURLOpener()
		)

		// When
		interactor.viewDidLoad()
		await waitUntil("날씨 추천 로드가 완료되지 않았습니다.") {
			fetchMusicForWeatherUseCase.executeCallCount == 1 &&
			presenter.loadingStates == [true, false] &&
			presenter.updatedTracksHistory.last?.count == 1
		}

		// Then
		#expect(fetchMusicForWeatherUseCase.executeCallCount == 1)
		#expect(presenter.updatedWeatherHistory.last?.cityName == "Seoul")
		#expect(presenter.updatedTracksHistory.last?.map(\.title) == ["Track 1"])
		#expect(presenter.loadingStates == [true, false])
		#expect(presenter.errorMessages == [nil])
	}
}
