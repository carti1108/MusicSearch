import UIKit
import Testing
@testable import MusicSearch

@MainActor
private final class WeatherRecommendationListenerSpy: WeatherRecommendationPresentableListener {
	var viewDidLoadCallCount = 0
	var refreshCallCount = 0
	var selectedIndices: [Int] = []

	func viewDidLoad() {
		self.viewDidLoadCallCount += 1
	}

	func didTapRefresh() {
		self.refreshCallCount += 1
	}

	func didSelectTrack(at index: Int) {
		self.selectedIndices.append(index)
	}
}

@MainActor
struct WeatherRecommendationViewControllerTests {
	@Test
	func viewDidLoad하면_listener의viewDidLoad를호출하는지() {
		let viewController = WeatherRecommendationViewController()
		let listener = WeatherRecommendationListenerSpy()
		viewController.listener = listener

		viewController.loadViewIfNeeded()

		#expect(listener.viewDidLoadCallCount == 1)
	}

	@Test
	func update를호출하면_트랙컬렉션이갱신되고섹션타이틀이노출되는지() async {
		let viewController = WeatherRecommendationViewController()
		viewController.loadViewIfNeeded()

		viewController.update(
			weather: TestDataFactory.makeWeather(temperature: 18, condition: .rain, description: "비", cityName: "Seoul"),
			tracks: [
				TestDataFactory.makeTrack(id: "1", title: "Track 1"),
				TestDataFactory.makeTrack(id: "2", title: "Track 2")
			]
		)
		await flushMainQueue()

		let labels = viewController.view.findSubviews(ofType: UILabel.self)
		let collectionView = viewController.view.findSubview(ofType: UICollectionView.self)

		#expect(labels.contains { $0.text == "오늘 날씨와 어울리는 선곡 🎧" && $0.isHidden == false })
		#expect(labels.contains { $0.text == "18°" })
		#expect(labels.contains { $0.text == "비" })
		#expect(labels.contains { $0.text == "Seoul" })
		#expect(collectionView?.numberOfItems(inSection: 0) == 2)
	}

	@Test
	func didSelectItemAt을호출하면_listener에선택인덱스를전달하는지() async throws {
		let viewController = WeatherRecommendationViewController()
		let listener = WeatherRecommendationListenerSpy()
		viewController.listener = listener
		viewController.loadViewIfNeeded()
		viewController.update(
			weather: TestDataFactory.makeWeather(),
			tracks: [
				TestDataFactory.makeTrack(id: "1"),
				TestDataFactory.makeTrack(id: "2")
			]
		)
		await flushMainQueue()

		let collectionView = try #require(viewController.view.findSubview(ofType: UICollectionView.self))
		viewController.collectionView(collectionView, didSelectItemAt: IndexPath(item: 1, section: 0))

		#expect(listener.selectedIndices == [1])
	}

	@Test
	func showLoading을호출하면_로딩상태가변경되는지() {
		let viewController = WeatherRecommendationViewController()
		viewController.loadViewIfNeeded()

		viewController.showLoading(true)
		#expect(viewController.isShowingLoading == true)

		viewController.showLoading(false)
		#expect(viewController.isShowingLoading == false)
	}
}
