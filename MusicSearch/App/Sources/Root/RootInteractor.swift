//
//  RootInteractor.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs

protocol RootRouting: LaunchRouting {}

protocol RootPresentableListener: AnyObject {}

protocol RootPresentable: Presentable {
	var listener: RootPresentableListener? { get set }
}

protocol RootListener: AnyObject {}

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
