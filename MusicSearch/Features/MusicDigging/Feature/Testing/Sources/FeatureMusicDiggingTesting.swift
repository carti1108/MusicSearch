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
	public let fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase
	public let urlOpener: URLOpening

	public init(
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
		fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase,
		urlOpener: URLOpening = MockURLOpener()
	) {
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
		self.fetchTrackDeepLinkUseCase = fetchTrackDeepLinkUseCase
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
public final class MockFetchTrackDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
    public init() {}
	public func execute(track: Track) async -> URL? { nil }
	public 
}

@MainActor
public final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
    public init() {}
	public func execute(targetTrack: Track) async throws -> [Track] { [] }
}
