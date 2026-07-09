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

	private lazy var musicAppServiceInstance: MusicAppService = {
		SpotifyAppService(
			configuration: self.spotifyAPIConfiguration,
			networkManager: self.networkManager,
			authService: self.musicAuthServiceInstance
		)
	}()


	private lazy var artistImageServiceInstance: ArtistImageService = {
		SpotifyArtistImageService(
			configuration: self.spotifyAPIConfiguration,
			networkManager: self.networkManager,
			authService: self.musicAuthServiceInstance
		)
	}()

	private lazy var fetchArtistImageURLUseCaseInstance: FetchArtistImageURLUseCase = {
		FetchArtistImageURLUseCaseImpl(artistImageService: self.artistImageServiceInstance)
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
			musicAppService: self.musicAppServiceInstance
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

	private lazy var playlistExportServiceInstance: PlaylistExportService = {
		SpotifyPlaylistExportService(networkManager: self.networkManager)
	}()

	private lazy var exportPlaylistUseCaseInstance: ExportPlaylistUseCase = {
		ExportPlaylistUseCaseImpl(
			playlistExportService: self.playlistExportServiceInstance,
			authService: self.musicAuthServiceInstance
		)
	}()

	var archiveRepository: ArchiveRepository {
		self.archiveRepositoryInstance
	}

	var exportPlaylistUseCase: ExportPlaylistUseCase {
		self.exportPlaylistUseCaseInstance
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
	var musicAppService: MusicAppService {
		self.musicAppServiceInstance
	}
	var artistImageService: ArtistImageService {
		self.artistImageServiceInstance
	}

	var fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
		FetchCurrentWeatherUseCaseImpl(
			locationRepository: self.locationRepository,
			weatherRepository: self.weatherRepository
		)
	}

	var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
		FetchTrackDeepLinkUseCaseImpl(musicAppService: self.musicAppServiceInstance)
	}
	var fetchArtistDeepLinkUseCase: FetchArtistDeepLinkUseCase {
		FetchArtistDeepLinkUseCaseImpl(musicAppService: self.musicAppServiceInstance)
	}
	var fetchArtistImageURLUseCase: FetchArtistImageURLUseCase {
		self.fetchArtistImageURLUseCaseInstance
	}

	private lazy var musicAuthServiceInstance: MusicAuthService = {
		SpotifyAuthServiceImpl(networkManager: self.networkManager)
	}()

	var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
		GetMusicAccessTokenUseCaseImpl(authService: self.musicAuthServiceInstance)
	}
	var authorizeMusicUseCase: AuthorizeMusicUseCase {
		AuthorizeMusicUseCaseImpl(authService: self.musicAuthServiceInstance)
	}
	var disconnectMusicUseCase: DisconnectMusicUseCase {
		DisconnectMusicUseCaseImpl(authService: self.musicAuthServiceInstance)
	}

	var fetchUserProfileUseCase: FetchUserProfileUseCase {
		FetchUserProfileUseCaseImpl(authService: self.musicAuthServiceInstance)
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
