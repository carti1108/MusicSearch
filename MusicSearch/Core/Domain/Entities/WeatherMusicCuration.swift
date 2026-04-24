//
//  WeatherMusicCuration.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public struct WeatherMusicCuration: Sendable {
	let weather: Weather
	let moodTag: String
	let tracks: [Track]
}
