import MSDomain
//
//  Weather.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

public enum WeatherCondition: Sendable {
	case thunderstorm
	case drizzle
	case rain
	case snow
	case atmosphere
	case clear
	case clouds
	case unknown
}

public struct Weather: Equatable, Sendable {
	public let temperature: Double
	public let condition: WeatherCondition
	public let description: String
	public let iconCode: String
	public let cityName: String

	public init(
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
