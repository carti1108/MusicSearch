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
