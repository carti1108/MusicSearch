import MSDomain
import UIKit
import Testing
@testable import FeatureTrackSearch
@testable import FeatureTrackSearchTesting

@MainActor
private final class TrackSearchListenerSpy: TrackSearchPresentableListener {
	var updatedKeywords: [String] = []
	var retryCallCount = 0
	var selectedTracks: [Track] = []
	var reachBottomCallCount = 0

	func didUpdateSearchText(_ keyword: String) {
		self.updatedKeywords.append(keyword)
	}

	func didTapRetry() {
		self.retryCallCount += 1
	}

	func didSelectTrack(_ track: Track) {
		self.selectedTracks.append(track)
	}

	func didReachListBottom() {
		self.reachBottomCallCount += 1
	}
}

@MainActor
struct TrackSearchViewControllerTests {
	@Test
	func updateSearchResults를호출하면_listener에검색어를전달하는지() throws {
		let viewController = TrackSearchViewController()
		viewController.loadViewIfNeeded()
		viewController.navigationItem.searchController?.searchBar.text = "Muse"

		let listener = TrackSearchListenerSpy()
		viewController.listener = listener
		viewController.updateSearchResults(for: try #require(viewController.navigationItem.searchController))

		#expect(listener.updatedKeywords == ["Muse"])
	}

	@Test
	func updateTracks를호출하면_중복트랙을제거해컬렉션에표시하는지() async throws {
		let track = Track(id: "same-id", title: "Track", artist: "Artist", imageURL: nil)
		let viewController = TrackSearchViewController()
		viewController.loadViewIfNeeded()

		viewController.updateTracks([track, track])
		await flushMainQueue()

		let collectionView = try #require(viewController.view.findSubview(ofType: UICollectionView.self))
		#expect(collectionView.numberOfItems(inSection: 0) == 1)
	}

	@Test
	func 검색어가있는상태에서빈결과를업데이트하면_emptyLabel이보이는지() async {
		let viewController = TrackSearchViewController()
		viewController.loadViewIfNeeded()
		viewController.navigationItem.searchController?.searchBar.text = "Muse"

		viewController.updateTracks([])
		await flushMainQueue()

		let labels = viewController.view.findSubviews(ofType: UILabel.self)
		#expect(labels.contains { $0.text?.contains("검색 결과가 없습니다.") == true && $0.isHidden == false })
	}

	@Test
	func didSelectItemAt을호출하면_listener에선택한트랙을전달하는지() async throws {
		let viewController = TrackSearchViewController()
		let listener = TrackSearchListenerSpy()
		let track = Track(id: "1", title: "Track 1", artist: "Artist 1", imageURL: nil)
		viewController.listener = listener
		viewController.loadViewIfNeeded()
		viewController.updateTracks([track])
		await flushMainQueue()

		let collectionView = try #require(viewController.view.findSubview(ofType: UICollectionView.self))
		viewController.collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))

		#expect(listener.selectedTracks == [track])
	}

	@Test
	func showLoading을호출하면_인디케이터애니메이션상태가변경되는지() {
		let viewController = TrackSearchViewController()
		viewController.loadViewIfNeeded()

		viewController.showLoading(true)
		#expect(viewController.loadingIndicatorView.isAnimating == true)

		viewController.showLoading(false)
		#expect(viewController.loadingIndicatorView.isAnimating == false)
	}
}
