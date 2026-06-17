import MSDomain
//
//  ChartInteractorTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Foundation
import Testing
@testable import FeatureChart
import FeatureChartTesting
import ChartDomain

@MainActor
struct ChartInteractorTests {

	@Test("viewDidLoad 호출 시 트랙 차트를 포디움과 리스트로 분리하는가")
	func viewDidLoadLoadsTrackChart() async {
		// Given
		let presenter = ChartPresentableSpy()
		let fetchChartTopTracksUseCase = MockFetchChartTopTracksUseCase()
		fetchChartTopTracksUseCase.result = [
			Track(title: "Track 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Track 2", artist: "Artist 2", imageURL: nil),
			Track(title: "Track 3", artist: "Artist 3", imageURL: nil),
			Track(title: "Track 4", artist: "Artist 4", imageURL: nil)
		]
		let interactor = ChartInteractor(
			presenter: presenter,
			fetchChartTopTracksUseCase: fetchChartTopTracksUseCase,
			fetchChartTopArtistsUseCase: MockFetchChartTopArtistsUseCase(),
			fetchMusicAppDeepLinkUseCase: MockFetchMusicAppDeepLinkUseCaseForChartInteractor(),
			urlOpener: MockURLOpener()
		)

		// When
		interactor.viewDidLoad()
		await waitUntil("track 차트 로드가 완료되지 않았습니다.") {
			fetchChartTopTracksUseCase.executeCallCount == 1 &&
			presenter.loadingStates == [true, false] &&
			presenter.podiumItemsHistory.last?.count == 3 &&
			presenter.listItemsHistory.last?.count == 1
		}

		// Then
		#expect(fetchChartTopTracksUseCase.executeCallCount == 1)
		#expect(presenter.loadingStates == [true, false])
		#expect(presenter.errorMessages == [nil])
		#expect(presenter.podiumItemsHistory.last?.map(\.title) == ["Track 2", "Track 1", "Track 3"])
		#expect(presenter.listItemsHistory.last?.map(\.title) == ["Track 4"])
	}

	@Test("세그먼트 변경 시 아티스트 차트를 로드하고 현재 세그먼트를 갱신하는가")
	func didChangeSegmentLoadsArtistChart() async {
		// Given
		let presenter = ChartPresentableSpy()
		let fetchChartTopArtistsUseCase = MockFetchChartTopArtistsUseCase()
		fetchChartTopArtistsUseCase.result = [
			Artist(name: "Artist 1", imageURL: nil, listeners: "100"),
			Artist(name: "Artist 2", imageURL: nil, listeners: "200"),
			Artist(name: "Artist 3", imageURL: nil, listeners: "300")
		]
		let interactor = ChartInteractor(
			presenter: presenter,
			fetchChartTopTracksUseCase: MockFetchChartTopTracksUseCase(),
			fetchChartTopArtistsUseCase: fetchChartTopArtistsUseCase,
			fetchMusicAppDeepLinkUseCase: MockFetchMusicAppDeepLinkUseCaseForChartInteractor(),
			urlOpener: MockURLOpener()
		)

		// When
		interactor.didChangeSegment(index: 1)
		await waitUntil("artist 차트 로드가 완료되지 않았습니다.") {
			fetchChartTopArtistsUseCase.executeCallCount == 1 &&
			presenter.updatedSegmentIndices == [1] &&
			presenter.podiumItemsHistory.last?.count == 3
		}

		// Then
		#expect(fetchChartTopArtistsUseCase.executeCallCount == 1)
		#expect(presenter.updatedSegmentIndices == [1])
		#expect(presenter.podiumItemsHistory.last?.map(\.title) == ["Artist 2", "Artist 1", "Artist 3"])
	}
}
