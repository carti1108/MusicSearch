//
//  WeatherAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 1/23/26.
//

import Foundation
import NetworkLayer

public protocol WeatherAPIConfiguration {
	var baseURL: String { get }
	var apiPath: String { get }
	var apiKey: String { get }
	var units: String { get }
}

public struct DefaultWeatherAPIConfiguration: WeatherAPIConfiguration {
	public var baseURL: String { "https://api.openweathermap.org" }
	public var apiPath: String { "/data/2.5/weather" }
	public var apiKey: String {
		Bundle.main.object(forInfoDictionaryKey: "OPENWEATHERMAP_API_KEY") as? String ?? ""
	}
	public var units: String { "metric" }
	
	public init() {}
}

enum WeatherAPI {
	case fetchWeather(lat: Double, lon: Double, config: WeatherAPIConfiguration)
}

extension WeatherAPI: Requestable {
	var cachePolicy: CachePolicy {
		return .memory
	}

	var baseURL: URL {
		switch self {
		case .fetchWeather(_, _, let config):
			return URL(string: config.baseURL)!
		}
	}

	var path: String {
		switch self {
		case .fetchWeather(_, _, let config):
			return config.apiPath
		}
	}

	var method: HTTPMethod {
		return .get
	}

	var headers: [HTTPHeader.Field: String]? {
		return nil
	}

	var task: RequestTask {
		switch self {
		case .fetchWeather(let lat, let lon, let config):
			return .requestParameters(
				parameters: [
					"lat": lat,
					"lon": lon,
					"appid": config.apiKey,
					"units": config.units
				],
				encoding: URLQueryEncoder()
			)
		}
	}
}
