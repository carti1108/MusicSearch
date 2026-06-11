//
//  WeatherRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

public protocol WeatherRepository: Sendable {
	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather
}
