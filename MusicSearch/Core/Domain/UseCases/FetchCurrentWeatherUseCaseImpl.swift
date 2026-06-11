//
//  FetchCurrentWeatherUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

public protocol FetchCurrentWeatherUseCase: Sendable {
	func execute() async throws -> Weather
}

public struct FetchCurrentWeatherUseCaseImpl: FetchCurrentWeatherUseCase {

	private let locationRepository: LocationRepository
	private let weatherRepository: WeatherRepository

	public init(locationRepository: LocationRepository, weatherRepository: WeatherRepository) {
		self.locationRepository = locationRepository
		self.weatherRepository = weatherRepository
	}

	public func execute() async throws -> Weather {
		let location = try await self.locationRepository.fetchCurrentLocation()
		return try await self.weatherRepository.fetchCurrentWeather(
			latitude: location.latitude,
			longitude: location.longitude
		)
	}
}
