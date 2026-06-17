import MSDomain
import UIKit
import Testing
@testable import FeatureChart
import FeatureChartTesting

@MainActor
private final class ChartListenerSpy: ChartPresentableListener {
	var viewDidLoadCallCount = 0
	var changedSegments: [Int] = []
	var refreshCallCount = 0
	var selectedIndexPaths: [IndexPath] = []

	func viewDidLoad() {
		self.viewDidLoadCallCount += 1
	}

	func didChangeSegment(index: Int) {
		self.changedSegments.append(index)
	}

	func didTapRefresh() {
		self.refreshCallCount += 1
	}

	func didSelectItem(at indexPath: IndexPath) {
		self.selectedIndexPaths.append(indexPath)
	}
}

@MainActor
struct ChartViewControllerTests {
	@Test
	func viewDidLoad하면_listener의viewDidLoad를호출하는지() {
		let viewController = ChartViewController()
		let listener = ChartListenerSpy()
		viewController.listener = listener

		viewController.loadViewIfNeeded()

		#expect(listener.viewDidLoadCallCount == 1)
	}

	@Test
	func updateSegment를호출하면_segmentControl선택상태가변경되는지() throws {
		let viewController = ChartViewController()
		viewController.loadViewIfNeeded()

		viewController.updateSegment(to: 1)

		let segmentedControl = try #require(viewController.view.findSubview(ofType: UISegmentedControl.self))
		#expect(segmentedControl.selectedSegmentIndex == 1)
	}

	@Test
	func segmentControl값이변경되면_listener에선택인덱스를전달하는지() throws {
		let viewController = ChartViewController()
		let listener = ChartListenerSpy()
		viewController.listener = listener
		viewController.loadViewIfNeeded()

		let segmentedControl = try #require(viewController.view.findSubview(ofType: UISegmentedControl.self))
		segmentedControl.selectedSegmentIndex = 1
		segmentedControl.sendActions(for: .valueChanged)

		#expect(listener.changedSegments == [1])
	}

	@Test
	func update를호출하면_podium과list섹션이컬렉션에반영되는지() async throws {
		let viewController = ChartViewController()
		viewController.loadViewIfNeeded()

		viewController.update(
			podiumItems: [
				ChartItem(id: "1", rank: 2, title: "Track 2", subtitle: "Artist 2", imageURL: nil, type: .tracks),
				ChartItem(id: "2", rank: 1, title: "Track 1", subtitle: "Artist 1", imageURL: nil, type: .tracks),
				ChartItem(id: "3", rank: 3, title: "Track 3", subtitle: "Artist 3", imageURL: nil, type: .tracks)
			],
			listItems: [
				ChartItem(id: "4", rank: 4, title: "Track 4", subtitle: "Artist 4", imageURL: nil, type: .tracks),
				ChartItem(id: "5", rank: 5, title: "Track 5", subtitle: "Artist 5", imageURL: nil, type: .tracks)
			]
		)
		await flushMainQueue()

		let collectionView = try #require(viewController.view.findSubview(ofType: UICollectionView.self))
		#expect(collectionView.numberOfSections == 2)
		#expect(collectionView.numberOfItems(inSection: 0) == 3)
		#expect(collectionView.numberOfItems(inSection: 1) == 2)
	}

	@Test
	func didSelectItemAt을호출하면_listener에선택IndexPath를전달하는지() async throws {
		let viewController = ChartViewController()
		let listener = ChartListenerSpy()
		viewController.listener = listener
		viewController.loadViewIfNeeded()
		viewController.update(
			podiumItems: [
				ChartItem(id: "1", rank: 2, title: "Track 2", subtitle: "Artist 2", imageURL: nil, type: .tracks),
				ChartItem(id: "2", rank: 1, title: "Track 1", subtitle: "Artist 1", imageURL: nil, type: .tracks),
				ChartItem(id: "3", rank: 3, title: "Track 3", subtitle: "Artist 3", imageURL: nil, type: .tracks)
			],
			listItems: []
		)
		await flushMainQueue()

		let collectionView = try #require(viewController.view.findSubview(ofType: UICollectionView.self))
		let indexPath = IndexPath(item: 1, section: 0)
		viewController.collectionView(collectionView, didSelectItemAt: indexPath)

		#expect(listener.selectedIndexPaths == [indexPath])
	}
}
