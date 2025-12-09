//
//  FetchMusicForWeatherUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchMusicForWeatherUseCase {
	func execute() async throws -> WeatherMusicCuration
}
