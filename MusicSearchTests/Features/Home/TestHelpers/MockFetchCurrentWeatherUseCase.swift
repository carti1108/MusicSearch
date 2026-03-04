//
//  MockFetchCurrentWeatherUseCase.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
@testable import MusicSearch

final class MockFetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
	var result: Weather?
	var errorToThrow: Error?
	var executeCallCount = 0

	func execute() async throws -> Weather {
		self.executeCallCount += 1

		if let error = self.errorToThrow {
			throw error
		}

		guard let result = self.result else {
			fatalError("MockFetchCurrentWeatherUseCase: result가 설정되지 않았습니다.")
		}

		return result
	}
}

