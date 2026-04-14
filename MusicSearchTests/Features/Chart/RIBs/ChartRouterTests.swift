//
//  ChartRouterTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Testing
import UIKit
import MicroRIBs
@testable import MusicSearch

@MainActor
struct ChartRouterTests {

	@Test("초기화 시 interactor router가 연결되는가")
	func initSetsInteractorRouter() {
		// Given
		let interactor = MockChartInteractableForRouter()
		let viewController = MockChartViewControllerForRouter()

		// When
		let router = ChartRouter(interactor: interactor, viewController: viewController)

		// Then
		#expect(interactor.router === router)
	}
}
