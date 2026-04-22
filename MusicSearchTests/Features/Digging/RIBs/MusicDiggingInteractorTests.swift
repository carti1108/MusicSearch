//
//  MusicDiggingInteractorTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Foundation
import Testing
import UIKit
@testable import MusicSearch

@MainActor
struct MusicDiggingInteractorTests {

	@Test("viewDidAppear 호출 시 seed track 기준 추천을 로드하는가")
	func viewDidAppearLoadsRecommendations() async {
		// Given
		let presenter = MusicDiggingPresentableSpy()
		let fetchSimilarTracksUseCase = MockFetchSimilarTracksUseCaseForInteractor()
		fetchSimilarTracksUseCase.result = [
			Track(title: "Recommendation 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Recommendation 2", artist: "Artist 2", imageURL: nil)
		]
		let seedTrack = Track(title: "Seed", artist: "Muse", imageURL: nil)
		let interactor = MusicDiggingInteractor(
			seedTrack: seedTrack,
			presenter: presenter,
			fetchSimilarTracksUseCase: fetchSimilarTracksUseCase,
			fetchMusicAppDeepLinkUseCase: MockFetchMusicAppDeepLinkUseCaseForMusicDiggingInteractor(),
			urlOpener: MockURLOpener()
		)

		// When
		interactor.viewDidAppear()
		await waitUntil("추천 곡 로드가 완료되지 않았습니다.") {
			fetchSimilarTracksUseCase.executeCallCount == 1 &&
			presenter.loadingStates == [true, false] &&
			presenter.recommendationsHistory.last?.count == 2
		}

		// Then
		#expect(fetchSimilarTracksUseCase.executeCallCount == 1)
		#expect(fetchSimilarTracksUseCase.targetTracks.map(\.title) == ["Seed"])
		#expect(presenter.seedTrackHistory.last?.title == "Seed")
		#expect(presenter.recommendationsHistory.last?.map(\.title) == ["Recommendation 1", "Recommendation 2"])
		#expect(presenter.loadingStates == [true, false])
		#expect(presenter.errorMessages == [nil])
	}

	@Test("추천 곡 선택 시 seed를 갱신하고 새 추천을 다시 로드하는가")
	func didSelectRecommendationReloadsFromSelectedTrack() async {
		// Given
		let presenter = MusicDiggingPresentableSpy()
		let fetchSimilarTracksUseCase = MockFetchSimilarTracksUseCaseForInteractor()
		let firstRecommendations = [
			Track(title: "Recommendation 1", artist: "Artist 1", imageURL: nil)
		]
		let secondRecommendations = [
			Track(title: "Recommendation 2", artist: "Artist 2", imageURL: nil)
		]
		fetchSimilarTracksUseCase.result = firstRecommendations
		let seedTrack = Track(title: "Seed", artist: "Muse", imageURL: nil)
		let interactor = MusicDiggingInteractor(
			seedTrack: seedTrack,
			presenter: presenter,
			fetchSimilarTracksUseCase: fetchSimilarTracksUseCase,
			fetchMusicAppDeepLinkUseCase: MockFetchMusicAppDeepLinkUseCaseForMusicDiggingInteractor(),
			urlOpener: MockURLOpener()
		)

		interactor.viewDidAppear()
		await waitUntil("첫 번째 추천 로드가 완료되지 않았습니다.") {
			fetchSimilarTracksUseCase.executeCallCount == 1 &&
			presenter.recommendationsHistory.last?.count == 1
		}
		fetchSimilarTracksUseCase.result = secondRecommendations

		// When
		interactor.didSelectRecommendation(at: IndexPath(item: 0, section: 0))
		await waitUntil("선택 후 재추천 로드가 완료되지 않았습니다.") {
			fetchSimilarTracksUseCase.executeCallCount == 2 &&
			presenter.recommendationsHistory.last?.count == 1 &&
			presenter.seedTrackHistory.last?.title == "Recommendation 1"
		}

		// Then
		#expect(fetchSimilarTracksUseCase.executeCallCount == 2)
		#expect(fetchSimilarTracksUseCase.targetTracks.map(\.title) == ["Seed", "Recommendation 1"])
		#expect(presenter.seedTrackHistory.last?.title == "Recommendation 1")
		#expect(presenter.recommendationsHistory.last?.map(\.title) == ["Recommendation 2"])
	}
}
