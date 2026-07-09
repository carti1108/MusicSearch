import Foundation
import MicroRIBs
import MSDomain
import MSUtil
import ChartDomain

@MainActor
public protocol ChartDependency: Dependency {
    var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase { get }
    var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase { get }
    var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase { get }
    var fetchArtistDeepLinkUseCase: FetchArtistDeepLinkUseCase { get }
    var urlOpener: URLOpening { get }
}

@MainActor
public protocol ChartBuildable: Buildable {
    func build(withListener listener: ChartListener) -> ChartRouting
}

@MainActor
public protocol ChartRouting: ViewableRouting {}

@MainActor
public protocol ChartListener: AnyObject {}
