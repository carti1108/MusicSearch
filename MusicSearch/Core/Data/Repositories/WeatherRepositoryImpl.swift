//
//  WeatherRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation
import NetworkLayer

final class WeatherRepositoryImpl: WeatherRepository {

	private let networkManager: NetworkRequesting
	private let configuration: WeatherAPIConfiguration

	init(
		networkManager: NetworkRequesting,
		configuration: WeatherAPIConfiguration = DefaultWeatherAPIConfiguration()
	) {
		self.networkManager = networkManager
		self.configuration = configuration
	}

	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather {
		guard !self.configuration.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
			  URL(string: self.configuration.baseURL) != nil
		else {
			throw WeatherError.configurationError
		}

		do {
			let response: WeatherResponseDTO = try await self.networkManager.perform(
				with: WeatherAPI.fetchWeather(lat: latitude, lon: longitude, config: self.configuration),
				as: WeatherResponseDTO.self
			)

			return response.toDomain()
		} catch let error as WeatherError {
			throw error
		} catch let error as NetworkError {
			throw WeatherError.networkError(error.localizedDescription)
		}
	}
}
