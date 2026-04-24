import Testing
import Foundation
@testable import MusicSearch

private struct StubLocalizedError: LocalizedError {
	let errorDescription: String?
}

@MainActor
struct WeatherRecommendationViewModelTests {
	@Test
	func 초기진입성공시_viewDidLoad하면_로딩후날씨와트랙을업데이트하는지() async throws {
		// given
		let view = SpyWeatherRecommendationView()
		let useCase = MockFetchMusicForWeatherUseCase()
		let weather = TestDataFactory.makeWeather(cityName: "Seoul")
		let tracks = [
			TestDataFactory.makeTrack(title: "Track 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(title: "Track 2", artist: "Artist 2")
		]
		useCase.result = TestDataFactory.makeWeatherMusicCuration(
			weather: weather,
			moodTag: "pop",
			tracks: tracks
		)
		let viewModel = WeatherRecommendationViewModel(view: view, fetchMusicForWeatherUseCase: useCase)

		// when
		viewModel.viewDidLoad()
		let didLoad = await AsyncTestHelper.waitUntil {
			view.updatedWeathers.count == 1 && view.loadingStates.last == false
		}

		// then
		#expect(didLoad)
		#expect(useCase.executeCallCount == 1)
		#expect(view.updatedWeathers.last == weather)
		#expect(view.updatedTracksHistory.last == tracks)
		#expect(view.loadingStates == [true, false])
		#expect((view.errorMessages.last ?? nil) == nil)
	}

	@Test
	func 이미데이터가로드된상태일때_viewDidLoad하면_재조회없이캐시를표시하는지() async throws {
		// given
		let view = SpyWeatherRecommendationView()
		let useCase = MockFetchMusicForWeatherUseCase()
		let weather = TestDataFactory.makeWeather(cityName: "Busan")
		let tracks = [TestDataFactory.makeTrack(title: "Cached Track", artist: "Artist")]
		useCase.result = TestDataFactory.makeWeatherMusicCuration(
			weather: weather,
			moodTag: "chill",
			tracks: tracks
		)
		let viewModel = WeatherRecommendationViewModel(view: view, fetchMusicForWeatherUseCase: useCase)

		viewModel.viewDidLoad()
		_ = await AsyncTestHelper.waitUntil {
			view.updatedWeathers.count == 1
		}
		view.updatedWeathers.removeAll()
		view.updatedTracksHistory.removeAll()
		view.loadingStates.removeAll()
		view.errorMessages.removeAll()

		// when
		viewModel.viewDidLoad()

		// then
		#expect(useCase.executeCallCount == 1)
		#expect(view.updatedWeathers.last == weather)
		#expect(view.updatedTracksHistory.last == tracks)
		#expect(view.loadingStates.isEmpty)
	}

	@Test
	func 기존데이터가있을때_didTapRefresh하면_최신결과로다시업데이트하는지() async throws {
		// given
		let view = SpyWeatherRecommendationView()
		let useCase = MockFetchMusicForWeatherUseCase()
		let firstCuration = TestDataFactory.makeWeatherMusicCuration(
			weather: TestDataFactory.makeWeather(cityName: "Seoul"),
			moodTag: "pop",
			tracks: [TestDataFactory.makeTrack(title: "Track 1", artist: "Artist 1")]
		)
		let refreshedCuration = TestDataFactory.makeWeatherMusicCuration(
			weather: TestDataFactory.makeWeather(cityName: "Jeju"),
			moodTag: "summer",
			tracks: [TestDataFactory.makeTrack(title: "Track 2", artist: "Artist 2")]
		)
		var executionIndex = 0
		useCase.executeHandler = {
			executionIndex += 1
			return executionIndex == 1 ? firstCuration : refreshedCuration
		}
		let viewModel = WeatherRecommendationViewModel(view: view, fetchMusicForWeatherUseCase: useCase)

		// when
		viewModel.viewDidLoad()
		_ = await AsyncTestHelper.waitUntil {
			view.updatedWeathers.last?.cityName == "Seoul"
		}
		viewModel.didTapRefresh()
		let didRefresh = await AsyncTestHelper.waitUntil {
			view.updatedWeathers.last?.cityName == "Jeju"
		}

		// then
		#expect(didRefresh)
		#expect(useCase.executeCallCount == 2)
		#expect(view.updatedTracksHistory.last?.first?.title == "Track 2")
	}

	@Test
	func 로컬라이즈드에러가발생할때_viewDidLoad하면_에러메시지를표시하는지() async {
		// given
		let view = SpyWeatherRecommendationView()
		let useCase = MockFetchMusicForWeatherUseCase()
		useCase.errorToThrow = StubLocalizedError(errorDescription: "추천을 불러오지 못했습니다.")
		let viewModel = WeatherRecommendationViewModel(view: view, fetchMusicForWeatherUseCase: useCase)

		// when
		viewModel.viewDidLoad()
		let didFail = await AsyncTestHelper.waitUntil {
			view.errorMessages.last == "추천을 불러오지 못했습니다." && view.loadingStates.last == false
		}

		// then
		#expect(didFail)
		#expect(view.updatedWeathers.isEmpty)
	}

	@Test
	func 유효한인덱스가있을때_didSelectTrack하면_coordinator에선택트랙을전달하는지() async throws {
		// given
		let view = SpyWeatherRecommendationView()
		let coordinator = SpyWeatherRecommendationCoordinator()
		let useCase = MockFetchMusicForWeatherUseCase()
		let tracks = [
			TestDataFactory.makeTrack(title: "Track 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(title: "Track 2", artist: "Artist 2")
		]
		useCase.result = TestDataFactory.makeWeatherMusicCuration(
			weather: TestDataFactory.makeWeather(),
			moodTag: "mood",
			tracks: tracks
		)
		let viewModel = WeatherRecommendationViewModel(view: view, fetchMusicForWeatherUseCase: useCase)
		viewModel.coordinator = coordinator
		viewModel.viewDidLoad()
		_ = await AsyncTestHelper.waitUntil {
			view.updatedTracksHistory.last == tracks
		}

		// when
		viewModel.didSelectTrack(at: 1)

		// then
		#expect(coordinator.selectedTracks == [tracks[1]])
	}
}
