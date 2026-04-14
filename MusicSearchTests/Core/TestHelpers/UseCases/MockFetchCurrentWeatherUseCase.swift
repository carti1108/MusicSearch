//
//  MockFetchCurrentWeatherUseCase.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
@testable import MusicSearch

final class MockFetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
	enum MockError: Error {
		case missingStub
	}

	var result: Weather?
	var errorToThrow: Error?
	var executeCallCount = 0

	func execute() async throws -> Weather {
		self.executeCallCount += 1

		if let error = self.errorToThrow {
			throw error
		}

		guard let result = self.result else { throw MockError.missingStub }
		return result
	}
}

