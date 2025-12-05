//
//  FetchCurrentWeatherUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

protocol FetchCurrentWeatherUseCase {
	func execute() async throws -> Weather
}
