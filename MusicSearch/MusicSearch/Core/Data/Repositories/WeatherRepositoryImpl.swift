//
//  WeatherRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation
import NetworkLayer

protocol WeatherAPIConfiguration {
	var baseURL: String { get }
	var apiPath: String { get }
	var apiKey: String { get }
	var units: String { get }
}

struct DefaultWeatherAPIConfiguration: WeatherAPIConfiguration {
	var baseURL: String { "https://api.openweathermap.org" }
	var apiPath: String { "/data/2.5/weather" }
	var apiKey: String {
		Bundle.main.object(forInfoDictionaryKey: "OPENWEATHERMAP_API_KEY") as? String ?? ""
	}
	var units: String { "metric" }
}

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
		do {
			let endpoint: Endpoint = try self.makeEndpoint(latitude: latitude, longitude: longitude)
			let response: WeatherResponseDTO = try await self.networkManager.request(
				with: endpoint,
				as: WeatherResponseDTO.self
			)

			return response.toDomain()
		} catch let error as WeatherError {
			throw error
		} catch let error as NetworkError {
			throw WeatherError.networkError(error.localizedDescription)
		}
	}

	private func makeEndpoint(latitude: Double, longitude: Double) throws -> Endpoint {
		guard let baseURL = URL(string: self.configuration.baseURL) else {
			throw WeatherError.configurationError
		}

		guard !self.configuration.apiKey.isEmpty else {
			throw WeatherError.configurationError
		}

		return Endpoint(
			baseURL: baseURL,
			path: self.configuration.apiPath,
			method: .get,
			queryParameters: [
				"lat": latitude,
				"lon": longitude,
				"appid": self.configuration.apiKey,
				"units": self.configuration.units
			]
		)
	}
}
