//
//  FeatureTrackSearchTesting.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import MusicDiggingDomain

import Foundation
import MSDomain
import MSUtil
import FeatureTrackSearchInterface
import TrackSearchDomain
import FeatureMusicDiggingInterface

@MainActor
public final class MockSearchTracksUseCase: SearchTracksUseCase {
	public var result: (tracks: [Track], totalResults: Int) = ([], 0)
	public var errorToThrow: Error?
	public var delay: TimeInterval?
	public var executeCallCount = 0
	public var lastQuery: String?
	public var lastLimit: Int?
	public var lastOffset: Int?

	public init() {}

	public func execute(
		query: String,
		limit: Int,
		offset: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		self.executeCallCount += 1
		self.lastQuery = query
		self.lastLimit = limit
		self.lastOffset = offset

		if let delay = delay {
			try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
		}

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
	public let fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase
	public let urlOpener: URLOpening
	public let musicDiggingBuilder: MusicDiggingBuildable

	public init(
		searchTracksUseCase: SearchTracksUseCase,
		fetchTracksByTagUseCase: FetchTracksByTagUseCase,
		fetchSimilarTracksUseCase: FetchSimilarTracksUseCase,
		fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase,
		urlOpener: URLOpening? = nil,
		musicDiggingBuilder: MusicDiggingBuildable? = nil
	) {
		self.searchTracksUseCase = searchTracksUseCase
		self.fetchTracksByTagUseCase = fetchTracksByTagUseCase
		self.fetchSimilarTracksUseCase = fetchSimilarTracksUseCase
		self.fetchTrackDeepLinkUseCase = fetchTrackDeepLinkUseCase
		self.urlOpener = urlOpener ?? MockURLOpener()
		self.musicDiggingBuilder = musicDiggingBuilder ?? MockMusicDiggingBuildable()
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
public final class MockFetchTracksByTagUseCase: FetchTracksByTagUseCase {
    public init() {}
	public func execute(tag: String) async throws -> [Track] { [] }
}

@MainActor
public final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
    public init() {}
	public func execute(targetTrack: Track) async throws -> [Track] { [] }
}
@MainActor
public final class MockMusicDiggingBuildable: MusicDiggingBuildable {
	public init() {}
	public func build(withListener listener: FeatureMusicDiggingInterface.MusicDiggingListener, seedTrack: MSDomain.Track) -> FeatureMusicDiggingInterface.MusicDiggingRouting {
		fatalError()
	}
}
