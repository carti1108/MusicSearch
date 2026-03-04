//
//  WeatherDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

struct WeatherResponseDTO: Decodable {
	let weather: [WeatherDescriptionDTO]
	let main: MainWeatherDataDTO
	let name: String

	func toDomain() -> Weather {
		let primaryWeather = self.weather.first

		return Weather(
			temperature: self.main.temp,
			condition: self.convertToWeatherCondition(id: primaryWeather?.id ?? 800),
			description: primaryWeather?.description ?? "",
			iconCode: primaryWeather?.icon ?? "",
			cityName: self.name
		)
	}

	private func convertToWeatherCondition(id: Int) -> WeatherCondition {
		switch id {
		case 200...232:
			return .thunderstorm
		case 300...321:
			return .drizzle
		case 500...531:
			return .rain
		case 600...622:
			return .snow
		case 701...781:
			return .atmosphere
		case 800:
			return .clear
		case 801...804:
			return .clouds
		default:
			return .unknown
		}
	}
}

struct WeatherDescriptionDTO: Decodable {
	let id: Int
	let main: String
	let description: String
	let icon: String
}

struct MainWeatherDataDTO: Decodable {
	let temp: Double
	let feelsLike: Double
	let tempMin: Double
	let tempMax: Double
	let pressure: Int
	let humidity: Int

	enum CodingKeys: String, CodingKey {
		case temp
		case feelsLike = "feels_like"
		case tempMin   = "temp_min"
		case tempMax   = "temp_max"
		case pressure
		case humidity
	}
}
