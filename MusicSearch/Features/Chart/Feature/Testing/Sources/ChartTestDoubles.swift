import MSDomain
import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
@testable import FeatureChart
import FeatureChartInterface
import ChartDomain


@MainActor
public final class ChartPresentableSpy: ChartPresentable {
	public weak var listener: ChartPresentableListener?

	public var updatedSegmentIndices: [Int] = []
	public var podiumItemsHistory: [[ChartItem]] = []
	public var listItemsHistory: [[ChartItem]] = []
	public var loadingStates: [Bool] = []
	public var errorMessages: [String?] = []

	public func updateSegment(to index: Int) {
		self.updatedSegmentIndices.append(index)
	}

	public func update(podiumItems: [ChartItem], listItems: [ChartItem]) {
		self.podiumItemsHistory.append(podiumItems)
		self.listItemsHistory.append(listItems)
	}

	public func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	public func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}
@MainActor
public final class MockFetchTrackDeepLinkUseCaseForChartInteractor: FetchTrackDeepLinkUseCase {
	public func execute(track: Track) async -> URL? { nil }
}
@MainActor
public final class MockFetchArtistDeepLinkUseCaseForChartInteractor: FetchArtistDeepLinkUseCase {
	public func execute(artist: String) async -> URL? { nil }
}
@MainActor
public final class MockChartInteractableForRouter: Interactor, ChartInteractable {
	public weak var router: ChartRouting?
	public weak var listener: ChartListener?
}
@MainActor
public final class MockChartViewControllerForRouter: UIViewController, ChartViewControllable {}
@MainActor
public final class MockFetchChartTopTracksUseCaseForBuilder: FetchChartTopTracksUseCase {
	public var executeCallCount = 0

	public func execute() async throws -> [Track] {
		self.executeCallCount += 1
		return [
			Track(title: "Track 1", artist: "Artist 1", imageURL: nil),
			Track(title: "Track 2", artist: "Artist 2", imageURL: nil),
			Track(title: "Track 3", artist: "Artist 3", imageURL: nil)
		]
	}
}
@MainActor
public final class MockFetchChartTopArtistsUseCaseForBuilder: FetchChartTopArtistsUseCase {
	public func execute() async throws -> [Artist] { [] }
}
@MainActor
public final class MockFetchTrackDeepLinkUseCaseForChartBuilder: FetchTrackDeepLinkUseCase {
	public init() {}
	public func execute(track: Track) async -> URL? { nil }
}
@MainActor
public final class MockFetchArtistDeepLinkUseCaseForChartBuilder: FetchArtistDeepLinkUseCase {
	public init() {}
	public func execute(artist: String) async -> URL? { nil }
}


