import Testing
import Foundation
import UIKit
@testable import MusicSearch

@MainActor
struct MusicDiggingViewModelTests {
	@Test
	func 초기추천이없을때_viewDidAppear하면_seed와추천곡을함께업데이트하는지() async throws {
		// given
		let seedTrack = TestDataFactory.makeTrack(id: "seed", title: "Seed", artist: "Artist")
		let recommendations = [
			TestDataFactory.makeTrack(id: "1", title: "Rec 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(id: "2", title: "Rec 2", artist: "Artist 2")
		]
		let view = SpyMusicDiggingView()
		let useCase = MockFetchSimilarTracksUseCase()
		useCase.result = .success(recommendations)
		let viewModel = MusicDiggingViewModel(
			seedTrack: seedTrack,
			view: view,
			fetchSimilarTracksUseCase: useCase
		)

		// when
		viewModel.viewDidAppear()
		let didLoad = await AsyncTestHelper.waitUntil {
			view.seedTrackHistory.last == seedTrack && view.recommendationHistory.last == recommendations && view.loadingStates.last == false
		}

		// then
		#expect(didLoad)
		#expect(useCase.executeCallCount == 1)
		#expect(useCase.requestedTracks == [seedTrack])
	}

	@Test
	func 이미추천곡이캐시된상태일때_viewDidAppear하면_재조회없이캐시를표시하는지() async throws {
		// given
		let seedTrack = TestDataFactory.makeTrack(id: "seed", title: "Seed", artist: "Artist")
		let recommendations = [TestDataFactory.makeTrack(id: "1", title: "Rec 1", artist: "Artist 1")]
		let view = SpyMusicDiggingView()
		let useCase = MockFetchSimilarTracksUseCase()
		useCase.result = .success(recommendations)
		let viewModel = MusicDiggingViewModel(
			seedTrack: seedTrack,
			view: view,
			fetchSimilarTracksUseCase: useCase
		)

		viewModel.viewDidAppear()
		_ = await AsyncTestHelper.waitUntil {
			view.recommendationHistory.last == recommendations
		}
		view.seedTrackHistory.removeAll()
		view.recommendationHistory.removeAll()
		view.loadingStates.removeAll()

		// when
		viewModel.viewDidAppear()

		// then
		#expect(useCase.executeCallCount == 1)
		#expect(view.seedTrackHistory.last == seedTrack)
		#expect(view.recommendationHistory.last == recommendations)
		#expect(view.loadingStates.isEmpty)
	}

	@Test
	func 추천결과가비어있을때_viewDidAppear하면_에러메시지를표시하는지() async throws {
		// given
		let seedTrack = TestDataFactory.makeTrack(id: "seed", title: "Seed", artist: "Artist")
		let view = SpyMusicDiggingView()
		let useCase = MockFetchSimilarTracksUseCase()
		useCase.result = .success([])
		let viewModel = MusicDiggingViewModel(
			seedTrack: seedTrack,
			view: view,
			fetchSimilarTracksUseCase: useCase
		)

		// when
		viewModel.viewDidAppear()
		let didFail = await AsyncTestHelper.waitUntil {
			view.errorMessages.last == "추천 곡을 불러오지 못했습니다." && view.loadingStates.last == false
		}

		// then
		#expect(didFail)
		#expect(view.recommendationHistory.last?.isEmpty == true)
	}

	@Test
	func 추천곡이선택될때_didSelectRecommendation하면_seed를교체하고재추천을로드하는지() async throws {
		// given
		let seedTrack = TestDataFactory.makeTrack(id: "seed", title: "Seed", artist: "Artist")
		let firstRecommendations = [
			TestDataFactory.makeTrack(id: "1", title: "Rec 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(id: "2", title: "Rec 2", artist: "Artist 2")
		]
		let secondRecommendations = [
			TestDataFactory.makeTrack(id: "3", title: "Rec 3", artist: "Artist 3")
		]
		let view = SpyMusicDiggingView()
		let useCase = MockFetchSimilarTracksUseCase()
		useCase.executeHandler = { track in
			track.id == seedTrack.id ? firstRecommendations : secondRecommendations
		}
		let viewModel = MusicDiggingViewModel(
			seedTrack: seedTrack,
			view: view,
			fetchSimilarTracksUseCase: useCase
		)

		viewModel.viewDidAppear()
		_ = await AsyncTestHelper.waitUntil {
			view.recommendationHistory.last == firstRecommendations
		}

		// when
		viewModel.didSelectRecommendation(at: IndexPath(item: 1, section: 0))
		let didReload = await AsyncTestHelper.waitUntil {
			view.seedTrackHistory.last?.id == firstRecommendations[1].id && view.recommendationHistory.last == secondRecommendations
		}

		// then
		#expect(didReload)
		#expect(useCase.executeCallCount == 2)
		#expect(useCase.requestedTracks.map(\.id) == ["seed", "2"])
	}

	@Test
	func seed트랙이탭될때_didTapSeedTrack하면_coordinator에선택트랙을전달하는지() {
		// given
		let seedTrack = TestDataFactory.makeTrack(id: "seed", title: "Seed", artist: "Artist")
		let view = SpyMusicDiggingView()
		let useCase = MockFetchSimilarTracksUseCase()
		let coordinator = SpyMusicDiggingCoordinator()
		let viewModel = MusicDiggingViewModel(
			seedTrack: seedTrack,
			view: view,
			fetchSimilarTracksUseCase: useCase
		)
		viewModel.coordinator = coordinator

		// when
		viewModel.didTapSeedTrack()

		// then
		#expect(coordinator.tappedSeedTracks == [seedTrack])
	}
}
