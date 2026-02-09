//
//  MockLocationManager.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/6/25.
//

import Foundation
import CoreLocation
import Testing
@testable import MusicSearch 

final class MockLocationManager: LocationManaging {

	var authorizationStatus: CLAuthorizationStatus = .notDetermined
	var desiredAccuracy: CLLocationAccuracy = 0
	var isRequestPermissionCalled = false
	var locationToReturn: CLLocation?
	var errorToThrow: Error?
	var delay: Duration = .seconds(0)

	func requestWhenInUseAuthorization() {
		isRequestPermissionCalled = true
	}

	func requestLocation() async throws -> CLLocation {
		if delay > .seconds(0) {
			try await Task.sleep(for: delay)
		}

		if let error = errorToThrow {
			throw error
		}

		if let location = locationToReturn {
			return location
		}

		throw WeatherError.unknown
	}
}
