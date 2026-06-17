import MSData
//
//  LocationRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation
import CoreLocation
import MSDomain
import WeatherRecommendationDomain

public protocol LocationManaging: Sendable {
	var authorizationStatus: CLAuthorizationStatus { get }
	var desiredAccuracy: CLLocationAccuracy { get set }
	func requestWhenInUseAuthorization()
	func requestLocation() async throws -> CLLocation
}

extension CLLocationManager: LocationManaging {
	public func requestLocation() async throws -> CLLocation {
		for try await update in CLLocationUpdate.liveUpdates() {
			if let location = update.location {
				return location
			}
		}
		throw WeatherError.locationFetchFailed
	}
}

public struct LocationRepositoryImpl: LocationRepository {

	private var locationManager: LocationManaging
	private let timeout: TimeInterval

	public init(
		locationManager: LocationManaging = CLLocationManager(),
		timeout: TimeInterval = 10.0
	) {
		self.locationManager = locationManager
		self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
		self.timeout = timeout
	}

	public func fetchCurrentLocation() async throws -> (latitude: Double, longitude: Double) {
		let status = self.locationManager.authorizationStatus

		switch status {
		case .denied, .restricted:
			throw WeatherError.locationPermissionDenied

		case .notDetermined:
			self.locationManager.requestWhenInUseAuthorization()

		case .authorizedWhenInUse, .authorizedAlways:
			break

		@unknown default:
			throw WeatherError.locationPermissionDenied
		}

		let manager = self.locationManager
		let location = try await self.withTimeout(self.timeout) {
			return try await manager.requestLocation()
		}

		return (location.coordinate.latitude, location.coordinate.longitude)
	}

	private func withTimeout<T: Sendable>(
		_ timeout: TimeInterval,
		perform task: @escaping @Sendable () async throws -> T
	) async throws -> T {
		try await withThrowingTaskGroup(of: T.self) { group in
			group.addTask {
				try await task()
			}

			group.addTask {
				try await Task.sleep(for: .seconds(timeout))
				throw WeatherError.locationFetchFailed
			}

			guard let result = try await group.next() else {
				group.cancelAll()
				throw WeatherError.unknown
			}

			group.cancelAll()

			return result
		}
	}
}
