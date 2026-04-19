import Testing
import Foundation
import UIKit
@testable import MusicSearch

@MainActor
struct ChartViewModelTests {
	@Test("차트 뷰모델이 트랙 차트를 podium과 list로 분리해 표시하는지 확인")
	func given_트랙차트조회가성공할때_viewDidLoad하면_podium과list를구성하는지() async throws {
		// given
		let view = SpyChartView()
		let trackUseCase = MockFetchChartTopTracksUseCase()
		let artistUseCase = MockFetchChartTopArtistsUseCase()
		let tracks = (1...5).map {
			TestDataFactory.makeTrack(id: "\($0)", title: "Track \($0)", artist: "Artist \($0)")
		}
		trackUseCase.result = .success(tracks)
		let viewModel = ChartViewModel(
			view: view,
			fetchChartTopTracksUseCase: trackUseCase,
			fetchChartTopArtistsUseCase: artistUseCase
		)

		// when
		viewModel.viewDidLoad()
		let didLoad = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.count == 3 && view.listHistory.last?.count == 2 && view.loadingStates.last == false
		}

		// then
		#expect(didLoad)
		#expect(view.podiumHistory.last?.map(\.title) == ["Track 2", "Track 1", "Track 3"])
		#expect(view.listHistory.last?.map(\.title) == ["Track 4", "Track 5"])
	}

	@Test("차트 뷰모델이 아티스트 세그먼트 변경 시 아티스트 차트를 로드하는지 확인")
	func given_아티스트세그먼트로변경할때_didChangeSegment하면_아티스트차트를로드하는지() async throws {
		// given
		let view = SpyChartView()
		let trackUseCase = MockFetchChartTopTracksUseCase()
		let artistUseCase = MockFetchChartTopArtistsUseCase()
		trackUseCase.result = .success((1...4).map {
			TestDataFactory.makeTrack(id: "\($0)", title: "Track \($0)", artist: "Artist \($0)")
		})
		artistUseCase.result = .success((1...4).map {
			TestDataFactory.makeArtist(id: "\($0)", name: "Artist \($0)", listeners: "\($0 * 100)")
		})
		let viewModel = ChartViewModel(
			view: view,
			fetchChartTopTracksUseCase: trackUseCase,
			fetchChartTopArtistsUseCase: artistUseCase
		)

		viewModel.viewDidLoad()
		_ = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.first?.type == .tracks
		}

		// when
		viewModel.didChangeSegment(index: 1)
		let didSwitch = await AsyncTestHelper.waitUntil {
			view.updatedSegments.last == 1 && view.podiumHistory.last?.first?.type == .artists && artistUseCase.executeCallCount == 1
		}

		// then
		#expect(didSwitch)
		#expect(view.podiumHistory.last?.map(\.title) == ["Artist 2", "Artist 1", "Artist 3"])
	}

	@Test("차트 뷰모델이 캐시된 세그먼트로 복귀할 때 재조회하지 않는지 확인")
	func given_세그먼트데이터가캐시되어있을때_didChangeSegment하면_재조회없이캐시를사용하는지() async throws {
		// given
		let view = SpyChartView()
		let trackUseCase = MockFetchChartTopTracksUseCase()
		let artistUseCase = MockFetchChartTopArtistsUseCase()
		trackUseCase.result = .success((1...4).map {
			TestDataFactory.makeTrack(id: "\($0)", title: "Track \($0)", artist: "Artist \($0)")
		})
		artistUseCase.result = .success((1...4).map {
			TestDataFactory.makeArtist(id: "\($0)", name: "Artist \($0)", listeners: "\($0 * 100)")
		})
		let viewModel = ChartViewModel(
			view: view,
			fetchChartTopTracksUseCase: trackUseCase,
			fetchChartTopArtistsUseCase: artistUseCase
		)

		viewModel.viewDidLoad()
		_ = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.first?.type == .tracks
		}
		viewModel.didChangeSegment(index: 1)
		_ = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.first?.type == .artists
		}

		// when
		viewModel.didChangeSegment(index: 0)
		await AsyncTestHelper.pause()

		// then
		#expect(trackUseCase.executeCallCount == 1)
		#expect(view.updatedSegments.last == 0)
		#expect(view.podiumHistory.last?.map(\.title) == ["Track 2", "Track 1", "Track 3"])
	}

	@Test("차트 뷰모델이 새로고침 시 현재 세그먼트 캐시를 무효화하고 다시 로드하는지 확인")
	func given_현재세그먼트를새로고침할때_didTapRefresh하면_캐시를무효화하고재조회하는지() async throws {
		// given
		let view = SpyChartView()
		let trackUseCase = MockFetchChartTopTracksUseCase()
		let artistUseCase = MockFetchChartTopArtistsUseCase()
		var executionIndex = 0
		trackUseCase.executeHandler = {
			executionIndex += 1
			if executionIndex == 1 {
				return (1...4).map {
					TestDataFactory.makeTrack(id: "\($0)", title: "Track \($0)", artist: "Artist \($0)")
				}
			}

			return (1...4).map {
				TestDataFactory.makeTrack(id: "r\($0)", title: "Refresh \($0)", artist: "Artist \($0)")
			}
		}
		let viewModel = ChartViewModel(
			view: view,
			fetchChartTopTracksUseCase: trackUseCase,
			fetchChartTopArtistsUseCase: artistUseCase
		)

		viewModel.viewDidLoad()
		_ = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.map(\.title) == ["Track 2", "Track 1", "Track 3"]
		}

		// when
		viewModel.didTapRefresh()
		let didRefresh = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.map(\.title) == ["Refresh 2", "Refresh 1", "Refresh 3"]
		}

		// then
		#expect(didRefresh)
		#expect(trackUseCase.executeCallCount == 2)
	}

	@Test("차트 뷰모델이 아이템이 3개 미만이면 빈 섹션을 표시하는지 확인")
	func given_차트아이템이세개미만일때_viewDidLoad하면_빈섹션을표시하는지() async throws {
		// given
		let view = SpyChartView()
		let trackUseCase = MockFetchChartTopTracksUseCase()
		let artistUseCase = MockFetchChartTopArtistsUseCase()
		trackUseCase.result = .success([
			TestDataFactory.makeTrack(title: "Track 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(title: "Track 2", artist: "Artist 2")
		])
		let viewModel = ChartViewModel(
			view: view,
			fetchChartTopTracksUseCase: trackUseCase,
			fetchChartTopArtistsUseCase: artistUseCase
		)

		// when
		viewModel.viewDidLoad()
		let didRenderEmpty = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.isEmpty == true && view.listHistory.last?.isEmpty == true && view.loadingStates.last == false
		}

		// then
		#expect(didRenderEmpty)
	}

	@Test("차트 뷰모델이 선택한 아이템을 coordinator에 전달하는지 확인")
	func given_차트아이템이선택될때_didSelectItem하면_coordinator에선택아이템을전달하는지() async throws {
		// given
		let view = SpyChartView()
		let trackUseCase = MockFetchChartTopTracksUseCase()
		let artistUseCase = MockFetchChartTopArtistsUseCase()
		let coordinator = SpyChartCoordinator()
		trackUseCase.result = .success((1...4).map {
			TestDataFactory.makeTrack(id: "\($0)", title: "Track \($0)", artist: "Artist \($0)")
		})
		let viewModel = ChartViewModel(
			view: view,
			fetchChartTopTracksUseCase: trackUseCase,
			fetchChartTopArtistsUseCase: artistUseCase
		)
		viewModel.coordinator = coordinator
		viewModel.viewDidLoad()
		_ = await AsyncTestHelper.waitUntil {
			view.podiumHistory.last?.count == 3
		}

		// when
		viewModel.didSelectItem(at: IndexPath(item: 0, section: 0))

		// then
		#expect(coordinator.selectedItems.count == 1)
		#expect(coordinator.selectedItems.first?.title == "Track 2")
	}

	@Test("차트 뷰모델이 로딩 실패 시 에러 메시지를 표시하는지 확인")
	func given_차트로딩에실패할때_viewDidLoad하면_에러메시지를표시하는지() async throws {
		// given
		enum TestError: Error {
			case failed
		}

		let view = SpyChartView()
		let trackUseCase = MockFetchChartTopTracksUseCase()
		let artistUseCase = MockFetchChartTopArtistsUseCase()
		trackUseCase.result = .failure(TestError.failed)
		let viewModel = ChartViewModel(
			view: view,
			fetchChartTopTracksUseCase: trackUseCase,
			fetchChartTopArtistsUseCase: artistUseCase
		)

		// when
		viewModel.viewDidLoad()
		let didFail = await AsyncTestHelper.waitUntil {
			view.errorMessages.last == "차트 정보를 불러오지 못했습니다." && view.loadingStates.last == false
		}

		// then
		#expect(didFail)
		#expect(view.podiumHistory.last?.isEmpty == true)
		#expect(view.listHistory.last?.isEmpty == true)
	}
}
