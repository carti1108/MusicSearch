import Foundation
@testable import MusicSearch

final class MockFetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
	var result: Weather?
	var errorToThrow: Error?
	var executeCallCount = 0

	func execute() async throws -> Weather {
		self.executeCallCount += 1

		if let errorToThrow {
			throw errorToThrow
		}

		guard let result else {
			throw TestDoubleError.missingStubbedValue("MockFetchCurrentWeatherUseCase.result")
		}

		return result
	}
}

final class MockFetchTracksByTagUseCase: FetchTracksByTagUseCase {
	var result: [Track] = []
	var errorToThrow: Error?
	var executeCallCount = 0
	var lastTag: String?

	func execute(tag: String) async throws -> [Track] {
		self.executeCallCount += 1
		self.lastTag = tag

		if let errorToThrow {
			throw errorToThrow
		}

		return self.result
	}
}

final class MockFetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
	var result: WeatherMusicCuration?
	var errorToThrow: Error?
	var executeHandler: (() async throws -> WeatherMusicCuration)?
	var executeCallCount = 0

	func execute() async throws -> WeatherMusicCuration {
		self.executeCallCount += 1

		if let executeHandler {
			return try await executeHandler()
		}

		if let errorToThrow {
			throw errorToThrow
		}

		guard let result else {
			throw TestDoubleError.missingStubbedValue("MockFetchMusicForWeatherUseCase.result")
		}

		return result
	}
}

final class MockSearchTracksUseCase: SearchTracksUseCase {
	var result: Result<(tracks: [Track], totalResults: Int), Error> = .success(([], 0))
	var executeHandler: ((String, Int, Int) async throws -> (tracks: [Track], totalResults: Int))?
	var executeCallCount = 0
	var requests: [(query: String, limit: Int, page: Int)] = []

	func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		self.executeCallCount += 1
		self.requests.append((query, limit, page))

		if let executeHandler {
			return try await executeHandler(query, limit, page)
		}

		switch self.result {
		case .success(let result):
			return result
		case .failure(let error):
			throw error
		}
	}
}

final class MockFetchSimilarTracksUseCase: FetchSimilarTracksUseCase {
	var result: Result<[Track], Error> = .success([])
	var executeHandler: ((Track) async throws -> [Track])?
	var executeCallCount = 0
	var requestedTracks: [Track] = []

	func execute(targetTrack: Track) async throws -> [Track] {
		self.executeCallCount += 1
		self.requestedTracks.append(targetTrack)

		if let executeHandler {
			return try await executeHandler(targetTrack)
		}

		switch self.result {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
}

final class MockFetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
	var result: Result<[Track], Error> = .success([])
	var executeHandler: (() async throws -> [Track])?
	var executeCallCount = 0

	func execute() async throws -> [Track] {
		self.executeCallCount += 1

		if let executeHandler {
			return try await executeHandler()
		}

		switch self.result {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}
}

final class MockFetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
	var result: Result<[Artist], Error> = .success([])
	var executeHandler: (() async throws -> [Artist])?
	var executeCallCount = 0

	func execute() async throws -> [Artist] {
		self.executeCallCount += 1

		if let executeHandler {
			return try await executeHandler()
		}

		switch self.result {
		case .success(let artists):
			return artists
		case .failure(let error):
			throw error
		}
	}
}
