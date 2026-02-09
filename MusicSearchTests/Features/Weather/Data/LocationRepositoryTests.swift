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

	@Test("정상적으로 권한이 있고 위치를 빠르게 가져오는 경우")
	func fetchSuccess() async throws {
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

	@Test("위치 권한이 거부(.denied)되었을 때 에러를 던지는가")
	func permissionDenied() async {
		// Given
		mockManager.authorizationStatus = .denied
		let repository = LocationRepositoryImpl(locationManager: mockManager)

		// When & Then
		await #expect(throws: WeatherError.locationPermissionDenied) {
			try await repository.fetchCurrentLocation()
		}
	}

	@Test("위치 요청 시간이 타임아웃 설정을 초과하면 실패하는가")
	func timeoutOccurs() async {
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

	@Test("권한이 미결정(.notDetermined)일 때 요청 메서드를 호출하는가")
	func requestPermissionIfNeeded() async throws {
		// Given
		mockManager.authorizationStatus = .notDetermined
		mockManager.locationToReturn = CLLocation(latitude: 10.0, longitude: 10.0)

		let repository = LocationRepositoryImpl(locationManager: mockManager, timeout: 1.0)

		// When
		_ = try await repository.fetchCurrentLocation()

		// Then
		#expect(mockManager.isRequestPermissionCalled, "권한 요청 함수가 호출되었어야 함")
	}
}
