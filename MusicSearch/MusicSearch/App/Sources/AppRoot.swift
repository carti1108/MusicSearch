//
//  AppRoot.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import UIKit

final class AppRoot {

	private let appComponent: AppComponent

	private lazy var weatherComponent: WeatherComponent = {
		WeatherComponent(dependency: appComponent)
	}()

	private lazy var musicComponent: MusicComponent = {
		MusicComponent(dependency: appComponent)
	}()

	private lazy var homeComponent: HomeComponent = {
		let dependency = CombinedHomeDependency(
			weatherComponent: weatherComponent,
			musicComponent: musicComponent
		)
		return HomeComponent(dependency: dependency)
	}()

	init(appComponent: AppComponent = AppComponent()) {
		self.appComponent = appComponent
	}

	func makeWeatherRecommendationViewController() -> UIViewController {
		homeComponent.makeWeatherRecommendationViewController()
	}
}

private struct CombinedHomeDependency: HomeDependency {
	let weatherComponent: WeatherComponent<AppComponent>
	let musicComponent: MusicComponent<AppComponent>

	var fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase {
		weatherComponent.fetchCurrentWeatherUseCase
	}

	var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
		musicComponent.fetchTracksByTagUseCase
	}
}

