//
//  MockLocationRepository.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/6/25.
//

import Foundation
import Testing
@testable import MusicSearch

final class MockLocationRepository: LocationRepository {

	var result: (latitude: Double, longitude: Double)?
	var errorToThrow: Error?

	func fetchCurrentLocation() async throws -> (latitude: Double, longitude: Double) {
		if let error = errorToThrow {
			throw error
		}
		if let result {
			return result
		}
		fatalError("MockLocation: 결과값이 설정되지 않음")
	}
}
