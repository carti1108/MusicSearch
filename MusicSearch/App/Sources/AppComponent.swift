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

	var  locationRepository: LocationRepository {
		LocationRepositoryImpl(locationManager: self.locationManager)
	}
	var  weatherRepository: WeatherRepository {
		WeatherRepositoryImpl(networkManager: self.networkManager)
	}
	var trackRepository: TrackRepository {
		TrackRepositoryImpl(networkManager: self.networkManager)
	}
	var chartRepository: ChartRepository {
		ChartRepositoryImpl(networkManager: self.networkManager)
	}

	var fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
		FetchCurrentWeatherUseCaseImpl(locationRepository: self.locationRepository, weatherRepository: self.weatherRepository)
	}

	let spotifyServiceInstance: SpotifyService // Singleton-like for lifecycle
	
	// ... existing init ...
	
	init(
		networkManager: NetworkRequesting = NetworkManager.shared,
		locationManager: LocationManaging = CLLocationManager(),
		weatherAPIConfiguration: WeatherAPIConfiguration = DefaultWeatherAPIConfiguration()
	) {
		self.networkManager = networkManager
		self.locationManager = locationManager
		self.weatherAPIConfiguration = weatherAPIConfiguration
		
		let spotifyClientId = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String ?? ""
		let spotifyClientSecret = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_SECRET") as? String ?? ""
		self.spotifyServiceInstance = SpotifyService(clientId: spotifyClientId, clientSecret: spotifyClientSecret)
	}
}

extension AppComponent: HomeDependency {
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		FetchMusicForWeatherUseCaseImpl(fetchCurrentWeatherUseCase: self.fetchCurrentWeatherUseCase, fetchTracksByTagUseCase: self.fetchTracksByTagUseCase)
	}
}

extension AppComponent: DiggingDependency {
	var searchTracksUseCase: any SearchTracksUseCase {
		SearchTrackUseCaseImpl(trackRepository: self.trackRepository)
	}

	var fetchTracksByTagUseCase: any FetchTracksByTagUseCase {
		FetchTracksByTagUseCaseImpl(trackRepository: self.trackRepository)
	}

	var fetchSimilarTrackUseCase: any FetchSimilarTracksUseCase {
		FetchSimilarTrackUseCaseImpl(trackRepository: self.trackRepository)
	}
}

extension AppComponent: TrendDependency {
	var fetchChartTopTracksUseCase: any FetchChartTopTracksUseCase {
		FetchChartTopTracksUseCaseImpl(chartRepository: self.chartRepository, trackRepository: self.trackRepository)
	}

	var fetchChartTopArtistsUseCase: any FetchChartTopArtistsUseCase {
		FetchChartTopArtistsUseCaseImpl(chartRepository: self.chartRepository)
	}
	
	var spotifyService: SpotifyServiceProtocol {
		self.spotifyServiceInstance
	}
}



