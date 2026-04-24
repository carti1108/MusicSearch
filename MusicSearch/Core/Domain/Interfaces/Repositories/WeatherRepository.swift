//
//  WeatherRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

protocol WeatherRepository: Sendable {
	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather
}
