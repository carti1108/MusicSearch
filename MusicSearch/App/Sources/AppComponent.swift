//
//  AppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation
import NetworkLayer
import CoreLocation

@MainActor
final class AppComponent {

	let networkManager: NetworkRequesting
	let locationManager: LocationManaging
	let weatherAPIConfiguration: WeatherAPIConfiguration
	let lastFMAPIConfiguration: LastFMAPIConfiguration
	let spotifyAPIConfiguration: SpotifyAPIConfiguration
	let urlOpener: URLOpening

	private lazy var musicAppRepositoryInstance: MusicAppRepository = {
		SpotifyAppRepository(
			configuration: self.spotifyAPIConfiguration,
			networkManager: self.networkManager
		)
	}()

	private lazy var fetchMusicAppDeepLinkUseCaseInstance: FetchMusicAppDeepLinkUseCase = {
		FetchMusicAppDeepLinkUseCaseImpl(musicAppRepository: self.musicAppRepositoryInstance)
	}()

	private lazy var artistImageRepositoryInstance: ArtistImageRepository = {
		SpotifyArtistImageRepository(
			configuration: self.spotifyAPIConfiguration,
			networkManager: self.networkManager
		)
	}()

	private lazy var fetchArtistImageURLUseCaseInstance: FetchArtistImageURLUseCase = {
		FetchArtistImageURLUseCaseImpl(artistImageRepository: self.artistImageRepositoryInstance)
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
		TrackRepositoryImpl(
			networkManager: self.networkManager,
			lastFMConfiguration: self.lastFMAPIConfiguration
		)
	}
	var chartRepository: ChartRepository {
		ChartRepositoryImpl(
			networkManager: self.networkManager,
			lastFMConfiguration: self.lastFMAPIConfiguration
		)
	}
	var musicAppRepository: MusicAppRepository {
		self.musicAppRepositoryInstance
	}
	var artistImageRepository: ArtistImageRepository {
		self.artistImageRepositoryInstance
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
	var fetchArtistImageURLUseCase: FetchArtistImageURLUseCase {
		self.fetchArtistImageURLUseCaseInstance
	}

	init(
		networkManager: NetworkRequesting = NetworkManager.shared,
		locationManager: LocationManaging = CLLocationManager(),
		weatherAPIConfiguration: WeatherAPIConfiguration = DefaultWeatherAPIConfiguration(),
		lastFMAPIConfiguration: LastFMAPIConfiguration = DefaultLastFMAPIConfiguration(),
		spotifyAPIConfiguration: SpotifyAPIConfiguration = DefaultSpotifyAPIConfiguration(),
		urlOpener: URLOpening = ApplicationURLOpener()
	) {
		self.networkManager = networkManager
		self.locationManager = locationManager
		self.weatherAPIConfiguration = weatherAPIConfiguration
		self.lastFMAPIConfiguration = lastFMAPIConfiguration
		self.spotifyAPIConfiguration = spotifyAPIConfiguration
		self.urlOpener = urlOpener
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
		FetchChartTopArtistsUseCaseImpl(
			chartRepository: self.chartRepository,
			artistImageEnrichmentService: ArtistImageEnrichmentServiceImpl(
				fetchArtistImageURLUseCase: self.fetchArtistImageURLUseCase
			)
		)
	}
}

extension AppComponent: RootDependency {}
