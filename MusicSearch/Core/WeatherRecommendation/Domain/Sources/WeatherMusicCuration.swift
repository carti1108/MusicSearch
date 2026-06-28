//
//  WeatherMusicCuration.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import MSDomain

import Foundation

public struct WeatherMusicCuration: Sendable {
	public let weather: Weather
	public let moodTag: String
	public let tracks: [Track]

	public init(weather: Weather, moodTag: String, tracks: [Track]) {
		self.weather = weather
		self.moodTag = moodTag
		self.tracks = tracks
	}
}
