//
//  FetchMusicForWeatherUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchMusicForWeatherUseCase {
	func execute() async throws -> WeatherMusicCuration
}

struct FetchMusicForWeatherUseCaseImpl: FetchMusicForWeatherUseCase {

	private let fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase
	private let fetchTracksByTagUseCase: FetchTracksByTagUseCase
	private let tagMapper: WeatherTagMapper

	init(
		fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase,
		fetchTracksByTagUseCase: FetchTracksByTagUseCase,
		tagMapper: WeatherTagMapper = WeatherTagMapper()
	) {
		self.fetchCurrentWeatherUseCase = fetchCurrentWeatherUseCase
		self.fetchTracksByTagUseCase = fetchTracksByTagUseCase
		self.tagMapper = tagMapper
	}

	func execute() async throws -> WeatherMusicCuration {
		let weather = try await self.fetchCurrentWeatherUseCase.execute()
		let tag = self.tagMapper.map(condition: weather.condition)
		let tracks = try await self.fetchTracksByTagUseCase.execute(tag: tag)

		return .init(weather: weather, moodTag: tag, tracks: tracks)
	}
}
