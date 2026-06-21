//
//  RootBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs
import FeatureChart
import FeatureChartInterface
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import FeatureTrackSearch
import FeatureTrackSearchInterface
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import FeatureArchive
import FeatureArchiveInterface
import FeatureAddArchive
import FeatureAddArchiveInterface
import FeatureArchiveSearch
import FeatureArchiveSearchInterface
import FeatureArchiveFolder
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import FeatureSettings
import FeatureSettingsInterface
import MSDomain
import MSUtil
import NetworkLayer
import WeatherRecommendationDomain
import TrackSearchDomain
import ChartDomain
import MusicDiggingDomain
import ArchiveDomain

@MainActor
protocol RootDependency: Dependency, WeatherRecommendationDependency, TrackSearchDependency, ChartDependency, MusicDiggingDependency, ArchiveDependency, AddArchiveDependency, ArchiveSearchDependency, ArchiveFolderDependency, SettingsDependency {}

@MainActor
final class RootComponent: Component<RootDependency>, WeatherRecommendationDependency, TrackSearchDependency, ChartDependency, MusicDiggingDependency, ArchiveDependency, AddArchiveDependency, ArchiveSearchDependency, ArchiveFolderDependency, SettingsDependency {
	
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}

	var fetchMusicAppDeepLinkUseCase: any FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}

	var urlOpener: URLOpening {
		self.dependency.urlOpener
	}

	var searchTracksUseCase: any SearchTracksUseCase {
		self.dependency.searchTracksUseCase
	}

	var fetchTracksByTagUseCase: any FetchTracksByTagUseCase {
		self.dependency.fetchTracksByTagUseCase
	}

	var fetchSimilarTracksUseCase: any FetchSimilarTracksUseCase {
		self.dependency.fetchSimilarTracksUseCase
	}

	var fetchChartTopTracksUseCase: any FetchChartTopTracksUseCase {
		self.dependency.fetchChartTopTracksUseCase
	}

	var fetchChartTopArtistsUseCase: any FetchChartTopArtistsUseCase {
		self.dependency.fetchChartTopArtistsUseCase
	}

	var weatherRecommendationBuilder: WeatherRecommendationBuildable {
		WeatherRecommendationBuilder(dependency: self)
	}

	var trackSearchBuilder: TrackSearchBuildable {
		TrackSearchBuilder(dependency: self)
	}

	var chartBuilder: ChartBuildable {
		ChartBuilder(dependency: self)
	}

	var musicDiggingBuilder: MusicDiggingBuildable {
		MusicDiggingBuilder(dependency: self)
	}

	
	var archiveRepository: any ArchiveRepository {
		self.dependency.archiveRepository
	}

	var musicAppRepository: any MusicAppRepository {
		self.dependency.musicAppRepository
	}
	
	var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
		dependency.archiveFolderDetailBuilder
	}

	var addArchiveBuilder: AddArchiveBuildable {
		AddArchiveBuilder(dependency: self)
	}
	
	var archiveSearchBuilder: ArchiveSearchBuildable {
		ArchiveSearchBuilder(dependency: self)
	}
	
	var archiveFolderBuilder: ArchiveFolderBuildable {
		ArchiveFolderBuilder(dependency: self)
	}
	
	var settingsBuilder: SettingsBuildable {
		SettingsBuilder(dependency: self)
	}

	var archiveBuilder: ArchiveBuildable {
		ArchiveBuilder(dependency: self)
	}

	var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase {
		self.dependency.manageSpotifyAuthUseCase
	}

	var fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase {
		self.dependency.fetchSpotifyProfileUseCase
	}
}

@MainActor
final class RootBuilder: Builder<RootDependency> {
	override init(dependency: RootDependency) {
		super.init(dependency: dependency)
	}

	func build() -> LaunchRouting {
		let component = RootComponent(dependency: self.dependency)
		let viewController = RootViewController()
		let interactor = RootInteractor(presenter: viewController)

		return RootRouter(
			interactor: interactor,
			viewController: viewController,
			weatherRecommendationBuilder: component.weatherRecommendationBuilder,
			trackSearchBuilder: component.trackSearchBuilder,
			chartBuilder: component.chartBuilder,
			archiveBuilder: component.archiveBuilder,
			settingsBuilder: component.settingsBuilder
		)
	}
}
