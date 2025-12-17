//
//  FetchCurrentWeatherUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

protocol FetchCurrentWeatherUseCase {
	func execute() async throws -> Weather
}

struct FetchCurrentWeatherUseCaseImpl: FetchCurrentWeatherUseCase {

	private let locationRepository: LocationRepository
	private let weatherRepository: WeatherRepository

	init(locationRepository: LocationRepository, weatherRepository: WeatherRepository) {
		self.locationRepository = locationRepository
		self.weatherRepository = weatherRepository
	}

	func execute() async throws -> Weather {
		let (latitude, longitude) = try await self.locationRepository.fetchCurrentLocation()
		let weather = try await self.weatherRepository.fetchCurrentWeather(
			latitude: latitude,
			longitude: longitude
		)

		return weather
	}
}
