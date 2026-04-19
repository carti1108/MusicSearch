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
		try self.validateConfiguration()
		do {
			let response: WeatherResponseDTO = try await self.networkManager.perform(
				with: WeatherAPI.fetchWeather(
					lat: latitude,
					lon: longitude,
					config: self.configuration
				),
				as: WeatherResponseDTO.self
			)
			return response.toDomain()
		} catch let error as WeatherError {
			throw error
		} catch let error as NetworkError {
			throw WeatherError.networkError(error.localizedDescription)
		} catch {
			throw WeatherError.networkError(error.localizedDescription)
		}
	}

	private func validateConfiguration() throws {
		let apiKey = self.configuration.apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !apiKey.isEmpty else {
			throw WeatherError.configurationError
		}

		guard let baseURL = URL(string: self.configuration.baseURL),
			  baseURL.scheme != nil,
			  baseURL.host != nil else {
			throw WeatherError.configurationError
		}
	}
}
