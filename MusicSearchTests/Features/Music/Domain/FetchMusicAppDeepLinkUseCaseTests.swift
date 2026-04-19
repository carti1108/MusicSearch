import Testing
import Foundation
@testable import MusicSearch

struct FetchMusicAppDeepLinkUseCaseTests {
	@Test("딥링크 유스케이스가 트랙 요청을 repository에 그대로 전달하는지 확인")
	func given_트랙이주어질때_execute하면_repository결과를반환하는지() async {
		// given
		let repository = MockMusicAppRepository()
		let track = TestDataFactory.makeTrack(title: "Track", artist: "Artist")
		let expectedURL = URL(string: "spotify://track/123")
		repository.trackURLToReturn = expectedURL
		let useCase = FetchMusicAppDeepLinkUseCaseImpl(musicAppRepository: repository)

		// when
		let url = await useCase.execute(track: track)

		// then
		let receivedTrack = repository.receivedTrack
		let callCount = repository.fetchTrackDeepLinkCallCount
		#expect(url == expectedURL)
		#expect(receivedTrack == track)
		#expect(callCount == 1)
	}

	@Test("딥링크 유스케이스가 아티스트 요청을 repository에 그대로 전달하는지 확인")
	func given_아티스트명이주어질때_execute하면_repository결과를반환하는지() async {
		// given
		let repository = MockMusicAppRepository()
		let artist = "Artist Name"
		let expectedURL = URL(string: "spotify://artist/123")
		repository.artistURLToReturn = expectedURL
		let useCase = FetchMusicAppDeepLinkUseCaseImpl(musicAppRepository: repository)

		// when
		let url = await useCase.execute(artist: artist)

		// then
		let receivedArtist = repository.receivedArtist
		let callCount = repository.fetchArtistDeepLinkCallCount
		#expect(url == expectedURL)
		#expect(receivedArtist == artist)
		#expect(callCount == 1)
	}
}
