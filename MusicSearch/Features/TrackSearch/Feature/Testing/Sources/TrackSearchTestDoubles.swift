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
import MusicDiggingDomain

@MainActor
public final class TrackSearchPresentableSpy: TrackSearchPresentable {
	public weak var listener: TrackSearchPresentableListener?

	public var updatedTracksHistory: [[Track]] = []
	public var loadingStates: [Bool] = []
	public var errorMessages: [String?] = []

	public func updateTracks(_ tracks: [Track]) {
		self.updatedTracksHistory.append(tracks)
	}

	public func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	public func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}
@MainActor
public final class MockTrackSearchInteractable: Interactor, TrackSearchInteractable {
	public weak var router: TrackSearchRouting?
	public weak var listener: TrackSearchListener?
}
@MainActor
public final class MockTrackSearchViewController: UIViewController, ViewControllable {}
@MainActor
public final class TrackSearchRoutingSpy: ViewableRouter<MockTrackSearchInteractable, MockTrackSearchViewController>, TrackSearchRouting {
	public var attachedSeedTrack: Track?

	public func attachMusicDigging(seedTrack: Track) {
		self.attachedSeedTrack = seedTrack
	}
}
@MainActor
public final class MockSearchTracksUseCaseForBuilder: SearchTracksUseCase {
	public init() {}
	public func execute(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
		([], 0)
	}
}
@MainActor
public final class MockFetchTracksByTagUseCaseForTrackSearchBuilder: FetchTracksByTagUseCase {
	public init() {}
	public func execute(tag: String) async throws -> [Track] { [] }
}
@MainActor
public final class MockFetchSimilarTracksUseCaseForTrackSearchBuilder: FetchSimilarTracksUseCase {
	public init() {}
	public func execute(targetTrack: Track) async throws -> [Track] { [] }
}
@MainActor
public final class MockFetchTrackDeepLinkUseCaseForTrackSearchBuilder: FetchTrackDeepLinkUseCase {
	public init() {}
	public func execute(track: Track) async -> URL? { nil }
	
}
@MainActor
public final class RouterTrackSearchPresentableSpy: TrackSearchPresentable {
	public weak var listener: TrackSearchPresentableListener?
	public init() {}

	public func updateTracks(_ tracks: [Track]) {}
	public func showLoading(_ isShow: Bool) {}
	public func showError(_ message: String?) {}
}
@MainActor
public final class RouterMockSearchTracksUseCase: SearchTracksUseCase {
	public init() {}
	public func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		([], 0)
	}
}
@MainActor
public final class RouterMockTrackSearchViewController: UIViewController, TrackSearchViewControllable {}

import FeatureMusicDiggingInterface
@MainActor
public final class MusicDiggingBuilderSpy: MusicDiggingBuildable {
	public init() {}
    public var buildCallCount = 0
    public var receivedListener: MusicDiggingListener?
    public var receivedSeedTrack: Track?
    public var buildHandler: ((MusicDiggingListener, Track) -> MusicDiggingRouting)?

    public func build(withListener listener: MusicDiggingListener, seedTrack: Track) -> MusicDiggingRouting {
        buildCallCount += 1
        receivedListener = listener
        receivedSeedTrack = seedTrack
        return buildHandler!(listener, seedTrack)
    }
}
@MainActor
public final class MockMusicDiggingInteractable: Interactor {
    public weak var router: MusicDiggingRouting?
    public weak var listener: MusicDiggingListener?
}
@MainActor
public final class MockMusicDiggingViewController: UIViewController, ViewControllable {}
@MainActor
public final class MusicDiggingRoutingSpy: ViewableRouter<MockMusicDiggingInteractable, MockMusicDiggingViewController>, MusicDiggingRouting {}

