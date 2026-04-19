//
//  Weather.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

enum WeatherCondition: Sendable {
	case thunderstorm
	case drizzle
	case rain
	case snow
	case atmosphere
	case clear
	case clouds
	case unknown
}

struct Weather: Equatable, Sendable {
	let temperature: Double
	let condition: WeatherCondition
	let description: String
	let iconCode: String
	let cityName: String

	init(
		temperature: Double,
		condition: WeatherCondition,
		description: String,
		iconCode: String,
		cityName: String
	) {
		self.temperature = temperature
		self.condition = condition
		self.description = description
		self.iconCode = iconCode
		self.cityName = cityName
	}
}
