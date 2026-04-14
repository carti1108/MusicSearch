//
//  RootInteractorTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Testing
@testable import MusicSearch

@MainActor
struct RootInteractorTests {

	@Test("초기화 시 presenter listener가 연결되는가")
	func initSetsPresenterListener() {
		// Given
		let presenter = RootPresentableSpy()

		// When
		let interactor = RootInteractor(presenter: presenter)

		// Then
		#expect(presenter.listener === interactor)
	}
}
