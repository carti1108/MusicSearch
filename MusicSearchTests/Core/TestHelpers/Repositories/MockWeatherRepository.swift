//
//  MockWeatherRepository.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/6/25.
//

import Foundation
import Testing
@testable import MusicSearch

final class MockWeatherRepository: WeatherRepository {
	enum MockError: Error {
		case missingStub
	}

	var result: Weather?
	var errorToThrow: Error?

	var receivedLat: Double?
	var receivedLon: Double?

	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather {
		self.receivedLat = latitude
		self.receivedLon = longitude

		if let error = errorToThrow {
			throw error
		}
		if let result {
			return result
		}
		throw MockError.missingStub
	}
}
