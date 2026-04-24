//
//  LocationRepositoryTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/5/25.
//

import Foundation
import Testing
import CoreLocation
@testable import MusicSearch

struct LocationRepositoryTests {
	let mockManager = MockLocationManager()

	@Test
	func 네트워크응답이정상적일때_fetchCurrentWeather하면_Weather도메인엔티티로잘변환되는지() async throws {
		// Given
		mockManager.authorizationStatus = .authorizedWhenInUse
		mockManager.locationToReturn = CLLocation(latitude: 37.5, longitude: 127.0)
		let repository = LocationRepositoryImpl(locationManager: mockManager, timeout: 1.0)

		// When
		let result = try await repository.fetchCurrentLocation()

		// Then
		#expect(result.latitude == 37.5)
		#expect(result.longitude == 127.0)
	}

	@Test
	func 위치권한이거부되었을때_fetchCurrentLocation하면_에러를던지는지() async {
		// Given
		mockManager.authorizationStatus = .denied
		let repository = LocationRepositoryImpl(locationManager: mockManager)

		// When & Then
		await #expect(throws: WeatherError.locationPermissionDenied) {
			try await repository.fetchCurrentLocation()
		}
	}

	@Test
	func 위치요청시간이타임아웃설정을초과할때_fetchCurrentLocation하면_실패하는지() async {
		// Given
		mockManager.authorizationStatus = .authorizedWhenInUse
		mockManager.locationToReturn = CLLocation(latitude: 37.5, longitude: 127.0)
		mockManager.delay = .seconds(2)
		let repository = LocationRepositoryImpl(locationManager: mockManager, timeout: 0.1)

		// When & Then
		await #expect(throws: WeatherError.locationFetchFailed) {
			try await repository.fetchCurrentLocation()
		}
	}

	@Test
	func 권한이미결정일때_fetchCurrentLocation하면_요청메서드를호출하는지() async throws {
		// Given
		mockManager.authorizationStatus = .notDetermined
		mockManager.locationToReturn = CLLocation(latitude: 10.0, longitude: 10.0)

		let repository = LocationRepositoryImpl(locationManager: mockManager, timeout: 1.0)

		// When
		_ = try await repository.fetchCurrentLocation()

		// Then
		#expect(mockManager.isRequestPermissionCalled, "권한 요청 함수가 호출되었어야 함")
	}

	@Test
	func 위치권한이restricted일때_fetchCurrentLocation하면_permissionDenied를던지는지() async {
		mockManager.authorizationStatus = .restricted
		let repository = LocationRepositoryImpl(locationManager: mockManager)

		await #expect(throws: WeatherError.locationPermissionDenied) {
			try await repository.fetchCurrentLocation()
		}
	}

	@Test
	func 위치조회중알수없는에러가나면_fetchCurrentLocation에서그에러를전파하는지() async {
		enum TestError: Error {
			case failed
		}

		mockManager.authorizationStatus = .authorizedWhenInUse
		mockManager.errorToThrow = TestError.failed
		let repository = LocationRepositoryImpl(locationManager: mockManager, timeout: 1.0)

		await #expect(throws: TestError.self) {
			try await repository.fetchCurrentLocation()
		}
	}
}
