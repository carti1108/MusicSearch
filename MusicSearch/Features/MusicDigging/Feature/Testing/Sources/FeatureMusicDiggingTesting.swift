//
//  FeatureMusicDiggingTesting.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

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
public final class MockFetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
    public init() {}
	public func execute(track: Track) async -> URL? { nil }
}

@MainActor
public final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
	public var result: [Track] = []
	public var errorToThrow: Error?
	public var delay: TimeInterval?

    public init() {}
	public func execute(targetTrack: Track) async throws -> [Track] {
		if let delay = delay {
			try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
		}
		if let error = errorToThrow {
			throw error
		}
		return result
	}
}
