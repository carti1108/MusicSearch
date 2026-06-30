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
import ChartData
import TrackSearchData
import WeatherRecommendationData
import WeatherRecommendationDomain
import TrackSearchDomain
import ChartDomain
import MusicDiggingDomain
import ArchiveDomain
import ArchiveData
import SwiftData

@MainActor
final class AppComponent: RootDependency {

	let networkManager: NetworkRequesting
	let locationManager: LocationManaging
	let weatherAPIConfiguration: WeatherAPIConfiguration
	let spotifyAPIConfiguration: SpotifyAPIConfiguration
	let urlOpener: URLOpening

	private lazy var musicAppRepositoryInstance: MusicAppRepository = {
		SpotifyAppRepository(
			configuration: self.spotifyAPIConfiguration,
			networkManager: self.networkManager,
			authRepository: self.spotifyAuthRepositoryInstance
		)
	}()

	private lazy var fetchMusicAppDeepLinkUseCaseInstance: FetchMusicAppDeepLinkUseCase = {
		FetchMusicAppDeepLinkUseCaseImpl(musicAppRepository: self.musicAppRepositoryInstance)
	}()

	private lazy var artistImageRepositoryInstance: ArtistImageRepository = {
		SpotifyArtistImageRepository(
			configuration: self.spotifyAPIConfiguration,
			networkManager: self.networkManager,
			authRepository: self.spotifyAuthRepositoryInstance
		)
	}()

	private lazy var fetchArtistImageURLUseCaseInstance: FetchArtistImageURLUseCase = {
		FetchArtistImageURLUseCaseImpl(artistImageRepository: self.artistImageRepositoryInstance)
	}()

	private lazy var imageDownloadRepositoryInstance: ImageDownloadRepository = {
		ImageDownloadRepositoryImpl()
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
		TrackRepositoryImpl(
			networkManager: self.networkManager,
			musicAppRepository: self.musicAppRepositoryInstance
		)
	}()

	private lazy var chartRepositoryInstance: ChartRepository = {
		ChartRepositoryImpl(networkManager: self.networkManager)
	}()


	private lazy var modelContainer: ModelContainer = {
		do {
			return try ModelContainer(for: SDArchivedTrack.self)
		} catch {
			do {
				let config = ModelConfiguration(isStoredInMemoryOnly: true)
				return try ModelContainer(for: SDArchivedTrack.self, configurations: config)
			} catch {
				fatalError("Could not initialize ModelContainer even in memory: \(error)")
			}
		}
	}()

	private lazy var archiveRepositoryInstance: ArchiveRepository = {
		ArchiveRepositoryImpl(modelContainer: self.modelContainer)
	}()

	private lazy var spotifyRepositoryInstance: SpotifyRepository = {
		SpotifyRepositoryImpl(networkManager: self.networkManager)
	}()

	private lazy var exportToSpotifyUseCaseInstance: ExportToSpotifyUseCase = {
		ExportToSpotifyUseCaseImpl(
			spotifyRepository: self.spotifyRepositoryInstance,
			authRepository: self.spotifyAuthRepositoryInstance
		)
	}()

	var archiveRepository: ArchiveRepository {
		self.archiveRepositoryInstance
	}

	var exportToSpotifyUseCase: ExportToSpotifyUseCase {
		self.exportToSpotifyUseCaseInstance
	}

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
	var imageDownloadRepository: ImageDownloadRepository {
		self.imageDownloadRepositoryInstance
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

	private lazy var spotifyAuthRepositoryInstance: SpotifyAuthRepository = {
		SpotifyAuthRepositoryImpl(networkManager: self.networkManager)
	}()

	var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
		ManageSpotifyAuthUseCaseImpl(authRepository: self.spotifyAuthRepositoryInstance)
	}

	var fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase {
		FetchSpotifyProfileUseCaseImpl(authRepository: self.spotifyAuthRepositoryInstance)
	}

	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		FetchMusicForWeatherUseCaseImpl(
			fetchCurrentWeatherUseCase: self.fetchCurrentWeatherUseCase,
			fetchTracksByTagUseCase: self.fetchTracksByTagUseCase
		)
	}

	var searchTracksUseCase: any SearchTracksUseCase {
		SearchTracksUseCaseImpl(trackRepository: self.trackRepository)
	}

	var fetchTracksByTagUseCase: any FetchTracksByTagUseCase {
		FetchTracksByTagUseCaseImpl(trackRepository: self.trackRepository)
	}

	var fetchSimilarTracksUseCase: any FetchSimilarTracksUseCase {
		FetchSimilarTracksUseCaseImpl(trackRepository: self.trackRepository)
	}

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
