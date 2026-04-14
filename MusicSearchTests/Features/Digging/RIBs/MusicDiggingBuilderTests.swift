//
//  MusicDiggingBuilderTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/14/26.
//

import Foundation
import Testing
@testable import MusicSearch

@MainActor
struct MusicDiggingBuilderTests {

	@Test("build 시 listener와 presenter가 정상 연결되고 seedTrack 의존성이 주입되는가")
	func buildWiresListenerPresenterAndSeedTrack() async {
		// Given
		let fetchSimilarTracksUseCase = MockFetchSimilarTracksUseCaseForBuilder()
		let dependency = MockMusicDiggingDependency(
			fetchSimilarTrackUseCase: fetchSimilarTracksUseCase,
			fetchMusicAppDeepLinkUseCase: MockFetchMusicAppDeepLinkUseCaseForMusicDiggingBuilder()
		)
		let builder = MusicDiggingBuilder(dependency: dependency)
		let listener = MockMusicDiggingListener()
		let seedTrack = Track(title: "Seed", artist: "Muse", imageURL: nil)

		// When
		let routing = builder.build(withListener: listener, seedTrack: seedTrack)

		// Then
		#expect(routing is MusicDiggingRouter)
		guard let router = routing as? MusicDiggingRouter else {
			Issue.record("MusicDiggingRouter 타입이 반환되어야 합니다.")
			return
		}
		guard let interactor = router.interactor as? MusicDiggingInteractor else {
			Issue.record("MusicDiggingInteractor가 조립되어야 합니다.")
			return
		}
		guard let viewController = router.viewControllable as? MusicDiggingViewController else {
			Issue.record("MusicDiggingViewController가 조립되어야 합니다.")
			return
		}

		#expect(interactor.listener === listener)
		#expect(viewController.listener === interactor)
		#expect(fetchSimilarTracksUseCase.executeCallCount == 0)
		#expect(fetchSimilarTracksUseCase.lastTargetTrack == nil)
	}
}
