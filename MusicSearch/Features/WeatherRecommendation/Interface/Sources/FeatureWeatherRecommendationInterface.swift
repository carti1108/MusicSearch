import Foundation
import MicroRIBs
import MSDomain
import MSUtil

@MainActor
public protocol WeatherRecommendationBuildable: Buildable {
	func build(withListener listener: WeatherRecommendationListener) -> WeatherRecommendationRouting
}

@MainActor
public protocol WeatherRecommendationRouting: ViewableRouting {}

@MainActor
public protocol WeatherRecommendationListener: AnyObject {}

@MainActor
public protocol WeatherRecommendationDependency: Dependency {
	var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase { get }
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
	var urlOpener: URLOpening { get }
}
