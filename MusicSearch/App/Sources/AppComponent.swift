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
import FeatureChart
import FeatureChartInterface
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import FeatureTrackSearch
import FeatureTrackSearchInterface
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import WeatherRecommendationDomain
import TrackSearchDomain
import ChartDomain
import MusicDiggingDomain
import ArchiveDomain
import ArchiveData
import FeatureAddArchiveInterface
import FeatureAddArchive
import FeatureArchiveSearchInterface
import FeatureArchiveSearch
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import FeatureArchiveFolderDetail
import FeatureArchiveFolder
import FeatureSettingsInterface
import FeatureSettings
import SwiftData

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


	private lazy var modelContainer: ModelContainer = {
		do {
			return try ModelContainer(for: SDArchivedTrack.self)
		} catch {
			print("ModelContainer init failed, attempting to delete old store: \(error)")
			let url = URL.applicationSupportDirectory.appending(path: "default.store")
			try? FileManager.default.removeItem(at: url)
			let shmUrl = URL.applicationSupportDirectory.appending(path: "default.store-shm")
			try? FileManager.default.removeItem(at: shmUrl)
			let walUrl = URL.applicationSupportDirectory.appending(path: "default.store-wal")
			try? FileManager.default.removeItem(at: walUrl)
			do {
				return try ModelContainer(for: SDArchivedTrack.self)
			} catch {
				fatalError("Could not initialize ModelContainer even after deleting store: \(error)")
			}
		}
	}()

	private lazy var archiveRepositoryInstance: ArchiveRepository = {
		ArchiveRepositoryImpl(modelContext: self.modelContainer.mainContext)
	}()

	private lazy var spotifyRepositoryInstance: SpotifyRepository = {
		SpotifyRepositoryImpl(networkManager: self.networkManager)
	}()

	private lazy var exportToSpotifyUseCaseInstance: ExportToSpotifyUseCase = {
		ExportToSpotifyUseCaseImpl(spotifyRepository: self.spotifyRepositoryInstance)
	}()

	
	var addArchiveBuilder: AddArchiveBuildable {
		AddArchiveBuilder(dependency: self)
	}
	
	var archiveSearchBuilder: ArchiveSearchBuildable {
		ArchiveSearchBuilder(dependency: self)
	}
	
	var archiveFolderBuilder: ArchiveFolderBuildable {
		ArchiveFolderBuilder(dependency: self)
	}
	
	var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
		ArchiveFolderDetailBuilder(dependency: self)
	}
	
	var settingsBuilder: SettingsBuildable {
		SettingsBuilder(dependency: self)
	}

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

	var musicDiggingBuilder: any MusicDiggingBuildable {
		MusicDiggingBuilder(dependency: self)
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

@MainActor
extension AppComponent: RootDependency {}

@MainActor
extension AppComponent: ArchiveSearchDependency {}

@MainActor
extension AppComponent: ArchiveFolderDependency {}

@MainActor
extension AppComponent: ArchiveFolderDetailDependency {}

@MainActor
extension AppComponent: SettingsDependency {}
