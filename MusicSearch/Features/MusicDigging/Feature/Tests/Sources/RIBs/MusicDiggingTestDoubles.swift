import MSDomain
import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
@testable import FeatureMusicDigging
import FeatureMusicDiggingInterface
import MusicDiggingDomain
import FeatureMusicDiggingTesting

@MainActor
final class MockMusicDiggingInteractable: Interactor, MusicDiggingInteractable {
	weak var router: MusicDiggingRouting?
	weak var listener: MusicDiggingListener?
}

@MainActor
final class MockMusicDiggingViewController: UIViewController, MusicDiggingViewControllable {}

@MainActor
final class MusicDiggingRoutingSpy: ViewableRouter<MockMusicDiggingInteractable, MockMusicDiggingViewController>, MusicDiggingRouting {}

@MainActor
final class MusicDiggingBuilderSpy: MusicDiggingBuildable {
	var buildCallCount = 0
	var receivedListener: MusicDiggingListener?
	var receivedSeedTrack: Track?
	var buildHandler: ((MusicDiggingListener, Track) -> MusicDiggingRouting)?

	func build(
		withListener listener: MusicDiggingListener,
		seedTrack: Track
	) -> MusicDiggingRouting {
		self.buildCallCount += 1
		self.receivedListener = listener
		self.receivedSeedTrack = seedTrack
		if let buildHandler {
			return buildHandler(listener, seedTrack)
		}
		return MusicDiggingRoutingSpy(
			interactor: MockMusicDiggingInteractable(),
			viewController: MockMusicDiggingViewController()
		)
	}
}

@MainActor
final class MusicDiggingPresentableSpy: MusicDiggingPresentable {
	weak var listener: MusicDiggingPresentableListener?

	var seedTrackHistory: [Track] = []
	var recommendationsHistory: [[Track]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func updateSeedTrack(_ track: Track) {
		self.seedTrackHistory.append(track)
	}

	func updateRecommendations(_ tracks: [Track]) {
		self.recommendationsHistory.append(tracks)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
final class MockFetchSimilarTracksUseCaseForInteractor: FetchSimilarTracksUseCase {
	var result: [Track] = []
	var executeCallCount = 0
	var targetTracks: [Track] = []

	func execute(targetTrack: Track) async throws -> [Track] {
		self.executeCallCount += 1
		self.targetTracks.append(targetTrack)
		return self.result
	}
}

@MainActor
final class MockFetchTrackDeepLinkUseCaseForMusicDiggingInteractor: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	
}

@MainActor
final class MockFetchSimilarTracksUseCaseForBuilder: FetchSimilarTracksUseCase {
	var executeCallCount = 0
	var lastTargetTrack: Track?

	func execute(targetTrack: Track) async throws -> [Track] {
		self.executeCallCount += 1
		self.lastTargetTrack = targetTrack
		return [
			Track(title: "Recommendation", artist: "Artist", imageURL: nil)
		]
	}
}

@MainActor
final class MockFetchTrackDeepLinkUseCaseForMusicDiggingBuilder: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	
}

@MainActor
final class MockMusicDiggingInteractableForRouter: Interactor, MusicDiggingInteractable {
	weak var router: MusicDiggingRouting?
	weak var listener: MusicDiggingListener?
}

@MainActor
final class MockMusicDiggingViewControllerForRouter: UIViewController, MusicDiggingViewControllable {}
