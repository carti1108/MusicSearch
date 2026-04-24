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

