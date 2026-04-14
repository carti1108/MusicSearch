//
//  MockFetchTracksByTagUseCase.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
@testable import MusicSearch

final class MockFetchTracksByTagUseCase: FetchTracksByTagUseCase {
	var result: [Track] = []
	var errorToThrow: Error?
	var executeCallCount = 0
	var lastTag: String?

	func execute(tag: String) async throws -> [Track] {
		self.executeCallCount += 1
		self.lastTag = tag

		if let error = self.errorToThrow {
			throw error
		}

		return self.result
	}
}

