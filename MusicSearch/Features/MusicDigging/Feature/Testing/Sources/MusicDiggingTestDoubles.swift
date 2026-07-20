//
//  MusicDiggingTestDoubles.swift
//  MusicSearch
//
//  Created by Kiseok on 7/10/26.
//

import MSDomain
import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
@testable import FeatureMusicDigging
import FeatureMusicDiggingInterface
import MusicDiggingDomain

@MainActor
public final class MockMusicDiggingInteractable: Interactor, MusicDiggingInteractable {
	public weak var router: MusicDiggingRouting?
	public weak var listener: MusicDiggingListener?
}
@MainActor
public final class MockMusicDiggingViewController: UIViewController, MusicDiggingViewControllable {}
@MainActor
public final class MusicDiggingRoutingSpy: ViewableRouter<MockMusicDiggingInteractable, MockMusicDiggingViewController>, MusicDiggingRouting {}
@MainActor
public final class MusicDiggingBuilderSpy: MusicDiggingBuildable {
	public var buildCallCount = 0
	public var receivedListener: MusicDiggingListener?
	public var receivedSeedTrack: Track?
	public var buildHandler: ((MusicDiggingListener, Track) -> MusicDiggingRouting)?

	public func build(
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
public final class MusicDiggingPresentableSpy: MusicDiggingPresentable {
	public weak var listener: MusicDiggingPresentableListener?

	public var seedTrackHistory: [Track] = []
	public var recommendationsHistory: [[Track]] = []
	public var loadingStates: [Bool] = []
	public var errorMessages: [String?] = []

	public func updateSeedTrack(_ track: Track) {
		self.seedTrackHistory.append(track)
	}

	public func updateRecommendations(_ tracks: [Track]) {
		self.recommendationsHistory.append(tracks)
	}

	public func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	public func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}
@MainActor
public final class MockFetchSimilarTracksUseCaseForInteractor: FetchSimilarTracksUseCase {
	public var result: [Track] = []
	public var executeCallCount = 0
	public var targetTracks: [Track] = []

	public func execute(targetTrack: Track) async throws -> [Track] {
		self.executeCallCount += 1
		self.targetTracks.append(targetTrack)
		return self.result
	}
}
@MainActor
public final class MockFetchTrackDeepLinkUseCaseForMusicDiggingInteractor: FetchTrackDeepLinkUseCase {
	public func execute(track: Track) async -> URL? { nil }
	
}
@MainActor
public final class MockFetchSimilarTracksUseCaseForBuilder: FetchSimilarTracksUseCase {
	public init() {}
	public var executeCallCount = 0
	public var lastTargetTrack: Track?

	public func execute(targetTrack: Track) async throws -> [Track] {
		self.executeCallCount += 1
		self.lastTargetTrack = targetTrack
		return [
			Track(title: "Recommendation", artist: "Artist", imageURL: nil)
		]
	}
}
@MainActor
public final class MockFetchTrackDeepLinkUseCaseForMusicDiggingBuilder: FetchTrackDeepLinkUseCase {
	public init() {}
	public func execute(track: Track) async -> URL? { nil }
	
}
@MainActor
public final class MockMusicDiggingInteractableForRouter: Interactor, MusicDiggingInteractable {
	public weak var router: MusicDiggingRouting?
	public weak var listener: MusicDiggingListener?
}
@MainActor
public final class MockMusicDiggingViewControllerForRouter: UIViewController, MusicDiggingViewControllable {}

