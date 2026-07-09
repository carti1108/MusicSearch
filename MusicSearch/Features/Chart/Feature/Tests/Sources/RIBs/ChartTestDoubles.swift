import MSDomain
import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
@testable import FeatureChart
import FeatureChartInterface
import ChartDomain
import FeatureChartTesting

@MainActor
final class ChartPresentableSpy: ChartPresentable {
	weak var listener: ChartPresentableListener?

	var updatedSegmentIndices: [Int] = []
	var podiumItemsHistory: [[ChartItem]] = []
	var listItemsHistory: [[ChartItem]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func updateSegment(to index: Int) {
		self.updatedSegmentIndices.append(index)
	}

	func update(podiumItems: [ChartItem], listItems: [ChartItem]) {
		self.podiumItemsHistory.append(podiumItems)
		self.listItemsHistory.append(listItems)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
final class MockFetchTrackDeepLinkUseCaseForChartInteractor: FetchTrackDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
}

@MainActor
final class MockFetchArtistDeepLinkUseCaseForChartInteractor: FetchArtistDeepLinkUseCase {
	func execute(artist: String) async -> URL? { nil }
}

@MainActor
final class MockChartInteractableForRouter: Interactor, ChartInteractable {
	weak var router: ChartRouting?
	weak var listener: ChartListener?
}

@MainActor
final class MockChartViewControllerForRouter: UIViewController, ChartViewControllable {}

@MainActor
final class MockFetchChartTopTracksUseCaseForBuilder: FetchChartTopTracksUseCase {
	var executeCallCount = 0

	func execute() async throws -> [Track] {
		self.executeCallCount += 1
		return [
			Track(title: "Track 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Track 2", artist: "Artist 2", imageURL: nil),
			Track(title: "Track 3", artist: "Artist 3", imageURL: nil)
		]
	}
}

@MainActor
final class MockFetchChartTopArtistsUseCaseForBuilder: FetchChartTopArtistsUseCase {
	func execute() async throws -> [Artist] { [] }
}

@MainActor
final class MockFetchTrackDeepLinkUseCaseForChartBuilder: FetchTrackDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
}

@MainActor
final class MockFetchArtistDeepLinkUseCaseForChartBuilder: FetchArtistDeepLinkUseCase {
	func execute(artist: String) async -> URL? { nil }
}

