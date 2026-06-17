import Foundation
import MSDomain
import MSUtil
import FeatureMusicDiggingInterface
import MusicDiggingDomain

@MainActor
public final class MockMusicDiggingListener: MusicDiggingListener {
    public init() {}
}

@MainActor
public final class MockMusicDiggingDependency: MusicDiggingDependency {
	public let fetchSimilarTracksUseCase: FetchSimilarTracksUseCase
	public let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	public let urlOpener: URLOpening

	public init(
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
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
public final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
    public init() {}
	public func execute(targetTrack: Track) async throws -> [Track] { [] }
}
