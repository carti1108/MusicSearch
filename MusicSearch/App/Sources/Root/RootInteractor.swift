//
//  RootInteractor.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs
import FeatureWeatherRecommendation
import FeatureWeatherRecommendationInterface
import FeatureChart
import FeatureChartInterface
import FeatureMusicDigging
import FeatureMusicDiggingInterface
import FeatureTrackSearch
import FeatureTrackSearchInterface

@MainActor
protocol RootRouting: LaunchRouting {}

@MainActor
protocol RootPresentableListener: AnyObject {}

@MainActor
protocol RootPresentable: Presentable {
	var listener: RootPresentableListener? { get set }
}

@MainActor
protocol RootListener: AnyObject {}

@MainActor
final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
	weak var router: RootRouting?
	weak var listener: RootListener?

	override init(presenter: RootPresentable) {
		super.init(presenter: presenter)
		presenter.listener = self
	}
}

extension RootInteractor: WeatherRecommendationListener {}
extension RootInteractor: TrackSearchListener {}
extension RootInteractor: ChartListener {}
