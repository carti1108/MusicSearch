import Foundation
import UIKit
import MicroRIBs
import MSDomain
import MSUtil
import FeatureChartInterface
import ChartDomain

@MainActor
public final class MockFetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
	public var result: [Track] = []
	public var executeCallCount = 0

	public init() {}

	public func execute() async throws -> [Track] {
		self.executeCallCount += 1
		return self.result
	}
}

@MainActor
public final class MockFetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
	public var result: [Artist] = []
	public var executeCallCount = 0

	public init() {}

	public func execute() async throws -> [Artist] {
		self.executeCallCount += 1
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
	public let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	public let urlOpener: URLOpening

	public init(
		fetchChartTopTracksUseCase: FetchChartTopTracksUseCase,
		fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.fetchChartTopTracksUseCase = fetchChartTopTracksUseCase
		self.fetchChartTopArtistsUseCase = fetchChartTopArtistsUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
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
