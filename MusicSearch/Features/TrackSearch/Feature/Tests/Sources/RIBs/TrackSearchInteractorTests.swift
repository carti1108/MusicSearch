//
//  TrackSearchInteractorTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import MSDomain

import Foundation
import Testing
import UIKit
import MicroRIBs
@testable import FeatureTrackSearch
@testable import FeatureTrackSearchTesting

@MainActor
struct TrackSearchInteractorTests {

	fileprivate var presenter: TrackSearchPresentableSpy
	fileprivate var mockUseCase: MockSearchTracksUseCase

	init() {
		self.presenter = TrackSearchPresentableSpy()
		self.mockUseCase = MockSearchTracksUseCase()
	}

	@Test("검색어 입력 후 검색 결과를 presenter에 반영하는가")
	func didUpdateSearchTextUpdatesPresenter() async throws {
		// Given
		let expectedTracks = [
			Track(title: "Hysteria", artist: "Muse", imageURL: nil),
			Track(title: "Plug In Baby", artist: "Muse", imageURL: nil)
		]
		self.mockUseCase.result = (expectedTracks, 2)

		let interactor = TrackSearchInteractor(
			presenter: self.presenter,
			debounceSeconds: 0.01,
			searchTracksUseCase: self.mockUseCase
		)

		// When
		interactor.didUpdateSearchText("Muse")
		await waitUntil("검색 결과가 presenter에 반영되지 않았습니다.") {
			self.mockUseCase.executeCallCount == 1 &&
			self.presenter.loadingStates == [true, false] &&
			self.presenter.updatedTracksHistory.last?.count == 2
		}

		// Then
		#expect(self.mockUseCase.executeCallCount == 1)
		#expect(self.mockUseCase.lastQuery == "Muse")
		#expect(self.mockUseCase.lastLimit == 20)
		#expect(self.mockUseCase.lastPage == 1)
		#expect(self.presenter.loadingStates == [true, false])
		#expect(self.presenter.errorMessages == [nil])
		#expect(self.presenter.updatedTracksHistory.last?.map(\.title) == ["Hysteria", "Plug In Baby"])
	}

	@Test("트랙 선택 시 MusicDigging attach를 요청하는가")
	func didSelectTrackRoutesToMusicDigging() {
		// Given
		let interactor = TrackSearchInteractor(
			presenter: self.presenter,
			searchTracksUseCase: self.mockUseCase
		)
		let router = TrackSearchRoutingSpy(
			interactor: MockTrackSearchInteractable(),
			viewController: MockTrackSearchViewController()
		)
		interactor.router = router
		let track = Track(title: "Time Is Running Out", artist: "Muse", imageURL: nil)

		// When
		interactor.didSelectTrack(track)

		// Then
		#expect(router.attachedSeedTrack?.title == "Time Is Running Out")
		#expect(router.attachedSeedTrack?.artist == "Muse")
	}
}
