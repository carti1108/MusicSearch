import MSDomain
import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
@testable import FeatureTrackSearch
import FeatureTrackSearchInterface
import TrackSearchDomain
import FeatureTrackSearchTesting

@MainActor
final class TrackSearchPresentableSpy: TrackSearchPresentable {
	weak var listener: TrackSearchPresentableListener?

	var updatedTracksHistory: [[Track]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func updateTracks(_ tracks: [Track]) {
		self.updatedTracksHistory.append(tracks)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
final class MockTrackSearchInteractable: Interactor, TrackSearchInteractable {
	weak var router: TrackSearchRouting?
	weak var listener: TrackSearchListener?
}

@MainActor
final class MockTrackSearchViewController: UIViewController, ViewControllable {}

@MainActor
final class TrackSearchRoutingSpy: ViewableRouter<MockTrackSearchInteractable, MockTrackSearchViewController>, TrackSearchRouting {
	var attachedSeedTrack: Track?

	func attachMusicDigging(seedTrack: Track) {
		self.attachedSeedTrack = seedTrack
	}
}

@MainActor
final class MockSearchTracksUseCaseForBuilder: SearchTracksUseCase {
	func execute(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
		([], 0)
	}
}

@MainActor
final class MockFetchTracksByTagUseCaseForTrackSearchBuilder: FetchTracksByTagUseCase {
	func execute(tag: String) async throws -> [Track] { [] }
}

@MainActor
final class MockFetchSimilarTracksUseCaseForTrackSearchBuilder: FetchSimilarTracksUseCase {
	func execute(targetTrack: Track) async throws -> [Track] { [] }
}

@MainActor
final class MockFetchMusicAppDeepLinkUseCaseForTrackSearchBuilder: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	func execute(artist: String) async -> URL? { nil }
}

@MainActor
final class RouterTrackSearchPresentableSpy: TrackSearchPresentable {
	weak var listener: TrackSearchPresentableListener?

	func updateTracks(_ tracks: [Track]) {}
	func showLoading(_ isShow: Bool) {}
	func showError(_ message: String?) {}
}

@MainActor
final class RouterMockSearchTracksUseCase: SearchTracksUseCase {
	func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		([], 0)
	}
}

@MainActor
final class RouterMockTrackSearchViewController: UIViewController, TrackSearchViewControllable {}
