//
//  WeatherComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation

final class WeatherComponent<T: WeatherDependency>: Component {
	typealias DependencyType = T

	private let dependency: T

	init(dependency: T) {
		self.dependency = dependency
	}
	var locationRepository: LocationRepository {
		LocationRepositoryImpl(locationManager: dependency.locationManager)
	}

	var weatherRepository: WeatherRepository {
		WeatherRepositoryImpl(
			networkManager: dependency.networkManager,
			configuration: dependency.weatherAPIConfiguration
		)
	}

	var fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
		FetchCurrentWeatherUseCaseImpl(
			locationRepository: locationRepository,
			weatherRepository: weatherRepository
		)
	}
}

