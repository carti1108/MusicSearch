//
//  AppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation
import NetworkLayer
import CoreLocation

final class AppComponent {

	let networkManager: NetworkRequesting
	let locationManager: LocationManaging
	let weatherAPIConfiguration: WeatherAPIConfiguration

	private lazy var musicAppRepositoryInstance: MusicAppRepository = {
		SpotifyAppRepository(
			clientId: Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String ?? "",
			clientSecret: Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_SECRET") as? String ?? "",
			networkManager: self.networkManager
		)
	}()

	private lazy var fetchMusicAppDeepLinkUseCaseInstance: FetchMusicAppDeepLinkUseCase = {
		FetchMusicAppDeepLinkUseCaseImpl(musicAppRepository: self.musicAppRepositoryInstance)
	}()

	var locationRepository: LocationRepository {
		LocationRepositoryImpl(locationManager: self.locationManager)
	}
	var weatherRepository: WeatherRepository {
		WeatherRepositoryImpl(
			networkManager: self.networkManager,
			configuration: self.weatherAPIConfiguration
		)
	}
	var trackRepository: TrackRepository {
		TrackRepositoryImpl(networkManager: self.networkManager)
	}
	var chartRepository: ChartRepository {
		ChartRepositoryImpl(networkManager: self.networkManager)
	}
	var musicAppRepository: MusicAppRepository {
		self.musicAppRepositoryInstance
	}

	var fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
		FetchCurrentWeatherUseCaseImpl(
			locationRepository: self.locationRepository,
			weatherRepository: self.weatherRepository
		)
	}

	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.fetchMusicAppDeepLinkUseCaseInstance
	}

	init(
		networkManager: NetworkRequesting = NetworkManager.shared,
		locationManager: LocationManaging = CLLocationManager(),
		weatherAPIConfiguration: WeatherAPIConfiguration = DefaultWeatherAPIConfiguration()
	) {
		self.networkManager = networkManager
		self.locationManager = locationManager
		self.weatherAPIConfiguration = weatherAPIConfiguration
	}
}

extension AppComponent: WeatherRecommendationDependency {
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: self.fetchCurrentWeatherUseCase,
			fetchTracksByTagUseCase: self.fetchTracksByTagUseCase
		)
	}
}

extension AppComponent: TrackSearchDependency {
	var searchTracksUseCase: any SearchTracksUseCase {
		SearchTracksUseCaseImpl(trackRepository: self.trackRepository)
	}

	var fetchTracksByTagUseCase: any FetchTracksByTagUseCase {
		FetchTracksByTagUseCaseImpl(trackRepository: self.trackRepository)
	}

	var fetchSimilarTrackUseCase: any FetchSimilarTracksUseCase {
		FetchSimilarTracksUseCaseImpl(trackRepository: self.trackRepository)
	}
}

extension AppComponent: ChartDependency {
	var fetchChartTopTracksUseCase: any FetchChartTopTracksUseCase {
		FetchChartTopTracksUseCaseImpl(
			chartRepository: self.chartRepository,
			trackRepository: self.trackRepository
		)
	}

	var fetchChartTopArtistsUseCase: any FetchChartTopArtistsUseCase {
		FetchChartTopArtistsUseCaseImpl(chartRepository: self.chartRepository)
	}
}

extension AppComponent: RootDependency {}
