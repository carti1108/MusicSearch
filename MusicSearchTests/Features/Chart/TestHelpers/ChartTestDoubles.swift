//
//  ChartTestDoubles.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//  

import Foundation
import UIKit
import MicroRIBs
@testable import MusicSearch

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
final class MockFetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
	var result: [Track] = []
	var executeCallCount = 0

	func execute() async throws -> [Track] {
		self.executeCallCount += 1
		return self.result
	}
}

@MainActor
final class MockFetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
	var result: [Artist] = []
	var executeCallCount = 0

	func execute() async throws -> [Artist] {
		self.executeCallCount += 1
		return self.result
	}
}

@MainActor
final class MockFetchMusicAppDeepLinkUseCaseForChartInteractor: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
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
final class MockFetchMusicAppDeepLinkUseCaseForChartBuilder: FetchMusicAppDeepLinkUseCase {
	func execute(track: Track) async -> URL? { nil }
	func execute(artist: String) async -> URL? { nil }
}

@MainActor
final class MockChartListener: ChartListener {}

@MainActor
final class MockChartDependency: ChartDependency {
	let fetchChartTopTracksUseCase: FetchChartTopTracksUseCase
	let fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase
	let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase

	init(
		fetchChartTopTracksUseCase: FetchChartTopTracksUseCase,
		fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	) {
		self.fetchChartTopTracksUseCase = fetchChartTopTracksUseCase
		self.fetchChartTopArtistsUseCase = fetchChartTopArtistsUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
	}
}

