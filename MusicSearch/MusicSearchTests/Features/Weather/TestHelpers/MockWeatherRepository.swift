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
		fatalError("MockWeather: 결과값이 설정되지 않음")
	}
}
