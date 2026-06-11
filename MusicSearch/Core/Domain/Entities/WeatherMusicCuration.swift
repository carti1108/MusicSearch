//
//  WeatherMusicCuration.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public struct WeatherMusicCuration: Sendable {
	public let weather: Weather
	public let moodTag: String
	public let tracks: [Track]
}
