//
//  WeatherRecommendationBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs
import MSDomain
import MSUtil
import FeatureWeatherRecommendationInterface



@MainActor
final class WeatherRecommendationComponent: Component<WeatherRecommendationDependency> {
	fileprivate var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase {
		self.dependency.fetchMusicForWeatherUseCase
	}

	fileprivate var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase {
		self.dependency.fetchMusicAppDeepLinkUseCase
	}
	
	fileprivate var urlOpener: URLOpening {
		self.dependency.urlOpener
	}
}



@MainActor
public final class WeatherRecommendationBuilder: Builder<WeatherRecommendationDependency>, WeatherRecommendationBuildable {
	public override init(dependency: WeatherRecommendationDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: WeatherRecommendationListener) -> WeatherRecommendationRouting {
		let component = WeatherRecommendationComponent(dependency: self.dependency)
		let viewController = WeatherRecommendationViewController()
		let interactor = WeatherRecommendationInteractor(
			presenter: viewController,
			fetchMusicForWeatherUseCase: component.fetchMusicForWeatherUseCase,
			fetchMusicAppDeepLinkUseCase: component.fetchMusicAppDeepLinkUseCase,
			urlOpener: component.urlOpener
		)
		interactor.listener = listener
		return WeatherRecommendationRouter(interactor: interactor, viewController: viewController)
	}
}
