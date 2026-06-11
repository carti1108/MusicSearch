//
//  AppComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation
import NetworkLayer
import CoreLocation
import MSDomain
import MSData
import MSUtil
import FeatureChart
import FeatureChartInterface
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import FeatureTrackSearch
import FeatureTrackSearchInterface
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface

@MainActor
final class AppComponent {

	let networkManager: NetworkRequesting
	let locationManager: LocationManaging
	let weatherAPIConfiguration: WeatherAPIConfiguration
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

	private lazy var locationRepositoryInstance: LocationRepository = {
		LocationRepositoryImpl(locationManager: self.locationManager)
	}()

	private lazy var weatherRepositoryInstance: WeatherRepository = {
		WeatherRepositoryImpl(
			networkManager: self.networkManager,
			configuration: self.weatherAPIConfiguration
		)
	}()

	private lazy var trackRepositoryInstance: TrackRepository = {
		TrackRepositoryImpl(networkManager: self.networkManager)
	}()

	private lazy var chartRepositoryInstance: ChartRepository = {
		ChartRepositoryImpl(networkManager: self.networkManager)
	}()

	var locationRepository: LocationRepository {
		self.locationRepositoryInstance
	}
	var weatherRepository: WeatherRepository {
		self.weatherRepositoryInstance
	}
	var trackRepository: TrackRepository {
		self.trackRepositoryInstance
	}
	var chartRepository: ChartRepository {
		self.chartRepositoryInstance
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
		spotifyAPIConfiguration: SpotifyAPIConfiguration = DefaultSpotifyAPIConfiguration(),
		urlOpener: URLOpening = ApplicationURLOpener()
	) {
		self.networkManager = networkManager
		self.locationManager = locationManager
		self.weatherAPIConfiguration = weatherAPIConfiguration
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

	var fetchSimilarTracksUseCase: any FetchSimilarTracksUseCase {
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
