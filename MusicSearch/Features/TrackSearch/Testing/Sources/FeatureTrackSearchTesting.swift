import Foundation
import MSDomain
import MSUtil
import FeatureTrackSearchInterface
import TrackSearchDomain

@MainActor
public final class MockSearchTracksUseCase: SearchTracksUseCase {
	public var result: (tracks: [Track], totalResults: Int) = ([], 0)
	public var errorToThrow: Error?
	public var executeCallCount = 0
	public var lastQuery: String?
	public var lastLimit: Int?
	public var lastPage: Int?

	public init() {}

	public func execute(
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
public final class MockTrackSearchListener: TrackSearchListener {
    public init() {}
}

@MainActor
public final class MockTrackSearchDependency: TrackSearchDependency {
	public let searchTracksUseCase: SearchTracksUseCase
	public let fetchTracksByTagUseCase: FetchTracksByTagUseCase
	public let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	public let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	public let urlOpener: URLOpening

	public init(
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

public final class MockURLOpener: URLOpening {
	public var openedURLs: [URL] = []

	public init() {}

	@MainActor
	public func open(_ url: URL) {
		self.openedURLs.append(url)
	}
}

@MainActor
public final class MockFetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    public init() {}
	public func execute(track: Track) async -> URL? { nil }
	public func execute(artist: String) async -> URL? { nil }
}

@MainActor
public final class MockFetchTracksByTagUseCase: FetchTracksByTagUseCase {
    public init() {}
	public func execute(tag: String) async throws -> [Track] { [] }
}

@MainActor
public final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
    public init() {}
	public func execute(targetTrack: Track) async throws -> [Track] { [] }
}
