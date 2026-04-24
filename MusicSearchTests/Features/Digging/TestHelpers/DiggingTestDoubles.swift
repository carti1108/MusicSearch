//
//  DiggingTestDoubles.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//  

import Foundation
import UIKit
import MicroRIBs
@testable import MusicSearch

// MARK: - TrackSearch

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
final class MockSearchTracksUseCase: SearchTracksUseCase {
	var result: (tracks: [Track], totalResults: Int) = ([], 0)
	var errorToThrow: Error?
	var executeCallCount = 0
	var lastQuery: String?
	var lastLimit: Int?
	var lastPage: Int?

	func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		self.executeCallCount += 1
		self.lastQuery = query
		self.lastLimit = limit
		self.lastPage = page

		if let error = self.errorToThrow {
			throw error
		}

		return self.result
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
final class MockTrackSearchListener: TrackSearchListener {}

@MainActor
final class MockTrackSearchDependency: TrackSearchDependency {
	let searchTracksUseCase: SearchTracksUseCase
	let fetchTracksByTagUseCase: FetchTracksByTagUseCase
	let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	let urlOpener: URLOpening

	init(
		searchTracksUseCase: SearchTracksUseCase,
		fetchTracksByTagUseCase: FetchTracksByTagUseCase,
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.searchTracksUseCase = searchTracksUseCase
		self.fetchTracksByTagUseCase = fetchTracksByTagUseCase
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
		self.urlOpener = urlOpener
	}
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

// MARK: - MusicDigging

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
final class MockFetchMusicAppDeepLinkUseCaseForMusicDiggingInteractor: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	func execute(artist: String) async -> URL? { nil }
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
final class MockFetchMusicAppDeepLinkUseCaseForMusicDiggingBuilder: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	func execute(artist: String) async -> URL? { nil }
}

@MainActor
final class MockMusicDiggingListener: MusicDiggingListener {}

@MainActor
final class MockMusicDiggingDependency: MusicDiggingDependency {
	let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	let urlOpener: URLOpening

	init(
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
		self.urlOpener = urlOpener
	}
}

@MainActor
final class MockMusicDiggingInteractableForRouter: Interactor, MusicDiggingInteractable {
	weak var router: MusicDiggingRouting?
	weak var listener: MusicDiggingListener?
}

@MainActor
final class MockMusicDiggingViewControllerForRouter: UIViewController, MusicDiggingViewControllable {}
