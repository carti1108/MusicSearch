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
import FeatureArchiveFolderDetail
import FeatureArchiveFolderDetailInterface
import FeatureArchiveTrackSearch
import FeatureArchiveTrackSearchInterface
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
protocol RootDependency: Dependency {
	// MARK: - UseCases
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase { get }
	var fetchTrackDeepLinkUseCase: any FetchTrackDeepLinkUseCase { get }
	var fetchArtistDeepLinkUseCase: any FetchArtistDeepLinkUseCase { get }
	var searchTracksUseCase: any SearchTracksUseCase { get }
	var fetchTracksByTagUseCase: any FetchTracksByTagUseCase { get }
	var fetchSimilarTracksUseCase: any FetchSimilarTracksUseCase { get }
	var fetchChartTopTracksUseCase: any FetchChartTopTracksUseCase { get }
	var fetchChartTopArtistsUseCase: any FetchChartTopArtistsUseCase { get }
	var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase { get }
	var authorizeMusicUseCase: AuthorizeMusicUseCase { get }
	var disconnectMusicUseCase: DisconnectMusicUseCase { get }
	var fetchUserProfileUseCase: FetchUserProfileUseCase { get }
	var exportPlaylistUseCase: any ExportPlaylistUseCase { get }

	// MARK: - Repositories
	var archiveRepository: any ArchiveRepository { get }


	// MARK: - Utilities
	var urlOpener: URLOpening { get }
}

@MainActor
final class RootComponent: Component<RootDependency>, WeatherRecommendationDependency, TrackSearchDependency, ChartDependency, MusicDiggingDependency, ArchiveDependency, AddArchiveDependency, ArchiveSearchDependency, ArchiveFolderDependency, ArchiveFolderDetailDependency, ArchiveTrackSearchDependency, SettingsDependency {

	// MARK: - UseCases
	var fetchMusicForWeatherUseCase: any FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}
	var fetchTrackDeepLinkUseCase: any FetchTrackDeepLinkUseCase {
		self.dependency.fetchTrackDeepLinkUseCase
	}
	var fetchArtistDeepLinkUseCase: any FetchArtistDeepLinkUseCase {
		self.dependency.fetchArtistDeepLinkUseCase
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
	var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase {
		self.dependency.getMusicAccessTokenUseCase
	}
	var authorizeMusicUseCase: AuthorizeMusicUseCase {
		self.dependency.authorizeMusicUseCase
	}
	var disconnectMusicUseCase: DisconnectMusicUseCase {
		self.dependency.disconnectMusicUseCase
	}
	var fetchUserProfileUseCase: FetchUserProfileUseCase {
		self.dependency.fetchUserProfileUseCase
	}
	var exportPlaylistUseCase: any ExportPlaylistUseCase {
		self.dependency.exportPlaylistUseCase
	}

	// MARK: - Repositories
	var archiveRepository: any ArchiveRepository {
		self.dependency.archiveRepository
	}


	// MARK: - Utilities
	var urlOpener: URLOpening {
		self.dependency.urlOpener
	}

	// MARK: - Child Builders
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
	var archiveBuilder: ArchiveBuildable {
		ArchiveBuilder(dependency: self)
	}
	var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
		ArchiveFolderDetailBuilder(dependency: self)
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
	var archiveTrackSearchBuilder: ArchiveTrackSearchBuildable {
		ArchiveTrackSearchBuilder(dependency: self)
	}
	var settingsBuilder: SettingsBuildable {
		SettingsBuilder(dependency: self)
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
