//
//  ChartTesting.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import ChartDomain
import FeatureChartInterface
import Foundation
import MSDomain
import MSUtil
import MicroRIBs
import UIKit

@MainActor
public final class MockFetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
	public var result: [Track] = []
	public var errorToThrow: Error?
	public var delay: TimeInterval?
	public var executeCallCount = 0

	public init() {}

	public func execute() async throws -> [Track] {
		self.executeCallCount += 1
		if let delay = delay {
			try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
		}
		if let error = errorToThrow {
			throw error
		}
		return self.result
	}
}

@MainActor
public final class MockFetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
	public var result: [Artist] = []
	public var errorToThrow: Error?
	public var delay: TimeInterval?
	public var executeCallCount = 0

	public init() {}

	public func execute() async throws -> [Artist] {
		self.executeCallCount += 1
		if let delay = delay {
			try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
		}
		if let error = errorToThrow {
			throw error
		}
		return self.result
	}
}

@MainActor
public final class MockChartListener: ChartListener {
	public init() {}
}

@MainActor
public final class MockChartDependency: ChartDependency {
	public let fetchChartTopTracksUseCase: FetchChartTopTracksUseCase
	public let fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase
	public let fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase
	public let fetchArtistDeepLinkUseCase: FetchArtistDeepLinkUseCase
	public let urlOpener: URLOpening

	public init(
		fetchChartTopTracksUseCase: FetchChartTopTracksUseCase,
		fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase,
		fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase,
		fetchArtistDeepLinkUseCase: FetchArtistDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.fetchChartTopTracksUseCase = fetchChartTopTracksUseCase
		self.fetchChartTopArtistsUseCase = fetchChartTopArtistsUseCase
		self.fetchTrackDeepLinkUseCase = fetchTrackDeepLinkUseCase
		self.fetchArtistDeepLinkUseCase = fetchArtistDeepLinkUseCase
		self.urlOpener = urlOpener
	}
}

public final class MockURLOpener: URLOpening {
	public var openedURLs: [URL] = []

	public init() {}

	@MainActor
	public func open(_ url: URL) {
		self.openedURLs.append(url)
	}
}
