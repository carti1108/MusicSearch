//
//  ChartBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs
import MSDomain
import MSUtil
import FeatureChartInterface
import ChartDomain

@MainActor
final class ChartComponent: Component<ChartDependency> {
	fileprivate var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase {
		self.dependency.fetchChartTopTracksUseCase
	}

	fileprivate var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase {
		self.dependency.fetchChartTopArtistsUseCase
	}

	fileprivate var fetchTrackDeepLinkUseCase: FetchTrackDeepLinkUseCase {
		self.dependency.fetchTrackDeepLinkUseCase
	}

	fileprivate var fetchArtistDeepLinkUseCase: FetchArtistDeepLinkUseCase {
		self.dependency.fetchArtistDeepLinkUseCase
	}

	fileprivate var urlOpener: URLOpening {
		self.dependency.urlOpener
	}
}

@MainActor
public final class ChartBuilder: Builder<ChartDependency>, ChartBuildable {
	public override init(dependency: ChartDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: ChartListener) -> ChartRouting {
		let component = ChartComponent(dependency: self.dependency)
		let viewController = ChartViewController()
		let interactor = ChartInteractor(
			presenter: viewController,
			fetchChartTopTracksUseCase: component.fetchChartTopTracksUseCase,
			fetchChartTopArtistsUseCase: component.fetchChartTopArtistsUseCase,
			fetchTrackDeepLinkUseCase: component.fetchTrackDeepLinkUseCase,
			fetchArtistDeepLinkUseCase: component.fetchArtistDeepLinkUseCase,
			urlOpener: component.urlOpener
		)
		interactor.listener = listener
		return ChartRouter(interactor: interactor, viewController: viewController)
	}
}
