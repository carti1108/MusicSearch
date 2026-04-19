import Testing
import Foundation
@testable import MusicSearch

@MainActor
struct TrackSearchViewModelTests {
	@Test("트랙 검색 뷰모델이 정상 검색어를 입력받으면 결과를 업데이트하는지 확인")
	func given_정상검색어가주어질때_didUpdateSearchText하면_검색결과를업데이트하는지() async throws {
		// given
		let view = SpyTrackSearchView()
		let useCase = MockSearchTracksUseCase()
		let tracks = [
			TestDataFactory.makeTrack(title: "Track 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(title: "Track 2", artist: "Artist 2")
		]
		useCase.result = .success((tracks, 2))
		let viewModel = TrackSearchViewModel(
			view: view,
			debounceSeconds: 0.01,
			searchTracksUseCase: useCase
		)

		// when
		viewModel.didUpdateSearchText("hello")
		let didSearch = await AsyncTestHelper.waitUntil {
			useCase.executeCallCount == 1 && view.updatedTracksHistory.last == tracks && view.loadingStates.last == false
		}

		// then
		#expect(didSearch)
		#expect(useCase.requests.last?.query == "hello")
		#expect(useCase.requests.last?.limit == 20)
		#expect(useCase.requests.last?.page == 1)
		#expect((view.errorMessages.last ?? nil) == nil)
	}

	@Test("트랙 검색 뷰모델이 공백 검색어를 입력받으면 상태를 초기화하는지 확인")
	func given_공백검색어가주어질때_didUpdateSearchText하면_검색상태를초기화하는지() async throws {
		// given
		let view = SpyTrackSearchView()
		let useCase = MockSearchTracksUseCase()
		let viewModel = TrackSearchViewModel(
			view: view,
			debounceSeconds: 0.01,
			searchTracksUseCase: useCase
		)

		// when
		viewModel.didUpdateSearchText("   ")
		let didReset = await AsyncTestHelper.waitUntil {
			view.updatedTracksHistory.last?.isEmpty == true
			&& view.loadingStates.last == false
			&& (view.errorMessages.last ?? nil) == nil
		}

		// then
		#expect(didReset)
		#expect(useCase.executeCallCount == 0)
	}

	@Test("트랙 검색 뷰모델이 재시도 시 마지막 키워드로 다시 검색하는지 확인")
	func given_이전검색이실패했을때_didTapRetry하면_마지막키워드로재검색하는지() async throws {
		// given
		enum TestError: Error {
			case failed
		}

		let view = SpyTrackSearchView()
		let useCase = MockSearchTracksUseCase()
		let recoveredTracks = [TestDataFactory.makeTrack(title: "Recovered", artist: "Artist")]
		var executionIndex = 0
		useCase.executeHandler = { query, _, _ in
			executionIndex += 1
			if executionIndex == 1 {
				throw TestError.failed
			}

			return (recoveredTracks, 1)
		}
		let viewModel = TrackSearchViewModel(
			view: view,
			debounceSeconds: 0.01,
			searchTracksUseCase: useCase
		)

		viewModel.didUpdateSearchText("retry-keyword")
		_ = await AsyncTestHelper.waitUntil {
			view.errorMessages.last == "검색 중 오류가 발생했습니다."
		}

		// when
		viewModel.didTapRetry()
		let didRetry = await AsyncTestHelper.waitUntil {
			useCase.executeCallCount == 2 && view.updatedTracksHistory.last == recoveredTracks
		}

		// then
		#expect(didRetry)
		#expect(useCase.requests.map { $0.query } == ["retry-keyword", "retry-keyword"])
	}

	@Test("트랙 검색 뷰모델이 더 불러오기가 가능할 때 다음 페이지를 이어붙이는지 확인")
	func given_다음페이지가존재할때_didReachListBottom하면_다음페이지결과를이어붙이는지() async throws {
		// given
		let view = SpyTrackSearchView()
		let useCase = MockSearchTracksUseCase()
		let firstPageTracks = (1...20).map {
			TestDataFactory.makeTrack(id: "\($0)", title: "Track \($0)", artist: "Artist \($0)")
		}
		let secondPageTracks = (21...25).map {
			TestDataFactory.makeTrack(id: "\($0)", title: "Track \($0)", artist: "Artist \($0)")
		}
		useCase.executeHandler = { _, _, page in
			if page == 1 {
				return (firstPageTracks, 25)
			}

			return (secondPageTracks, 25)
		}
		let viewModel = TrackSearchViewModel(
			view: view,
			debounceSeconds: 0.01,
			searchTracksUseCase: useCase
		)

		viewModel.didUpdateSearchText("load-more")
		_ = await AsyncTestHelper.waitUntil {
			view.updatedTracksHistory.last?.count == 20
		}

		// when
		viewModel.didReachListBottom()
		let didAppend = await AsyncTestHelper.waitUntil {
			useCase.executeCallCount == 2 && view.updatedTracksHistory.last?.count == 25
		}

		// then
		#expect(didAppend)
		#expect(useCase.requests.map { $0.page } == [1, 2])
	}

	@Test("트랙 검색 뷰모델이 더 불러올 데이터가 없으면 추가 조회하지 않는지 확인")
	func given_더불러올데이터가없을때_didReachListBottom하면_추가조회하지않는지() async throws {
		// given
		let view = SpyTrackSearchView()
		let useCase = MockSearchTracksUseCase()
		let tracks = [
			TestDataFactory.makeTrack(title: "Track 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(title: "Track 2", artist: "Artist 2")
		]
		useCase.result = .success((tracks, 2))
		let viewModel = TrackSearchViewModel(
			view: view,
			debounceSeconds: 0.01,
			searchTracksUseCase: useCase
		)

		viewModel.didUpdateSearchText("no-more")
		_ = await AsyncTestHelper.waitUntil {
			view.updatedTracksHistory.last == tracks
		}

		// when
		viewModel.didReachListBottom()
		await AsyncTestHelper.pause(for: .milliseconds(50))

		// then
		#expect(useCase.executeCallCount == 1)
	}

	@Test("트랙 검색 뷰모델이 선택한 트랙을 coordinator에 전달하는지 확인")
	func given_트랙이선택될때_didSelectTrack하면_coordinator에선택트랙을전달하는지() {
		// given
		let view = SpyTrackSearchView()
		let useCase = MockSearchTracksUseCase()
		let coordinator = SpyTrackSearchCoordinator()
		let selectedTrack = TestDataFactory.makeTrack(title: "Selected", artist: "Artist")
		let viewModel = TrackSearchViewModel(
			view: view,
			debounceSeconds: 0.01,
			searchTracksUseCase: useCase
		)
		viewModel.coordinator = coordinator

		// when
		viewModel.didSelectTrack(selectedTrack)

		// then
		#expect(coordinator.selectedTracks == [selectedTrack])
	}
}
