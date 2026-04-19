import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct ChartRepositoryTests {
	var mockNetworkManager: MockNetworkManager

	init() {
		self.mockNetworkManager = MockNetworkManager()
	}

	@Test("차트 트랙 repository가 DTO를 도메인 모델로 변환하는지 확인")
	mutating func given_차트트랙DTO가주어질때_fetchTopTracks하면_도메인으로변환하는지() async throws {
		// given
		self.mockNetworkManager.resultDTOByMethod["chart.gettoptracks"] = TestDataFactory.makeChartTopTracksResponseDTO(
			tracks: [
				TestDataFactory.makeChartTrackDTO(
					name: "Track A",
					artist: "Artist A",
					mbid: "mbid-a",
					imageURL: "http://image.test/track-a.jpg"
				)
			]
		)
		let repository = ChartRepositoryImpl(networkManager: self.mockNetworkManager)

		// when
		let tracks = try await repository.fetchTopTracks()

		// then
		#expect(tracks.count == 1)
		#expect(tracks[0].title == "Track A")
		#expect(tracks[0].artist == "Artist A")
		#expect(tracks[0].mbid == "mbid-a")
		#expect(tracks[0].imageURL?.absoluteString == "https://image.test/track-a.jpg")
		#expect(self.mockNetworkManager.requestedMethods == ["chart.gettoptracks"])
	}

	@Test("차트 아티스트 repository가 DTO를 도메인 모델로 변환하는지 확인")
	mutating func given_차트아티스트DTO가주어질때_fetchTopArtists하면_도메인으로변환하는지() async throws {
		// given
		self.mockNetworkManager.resultDTOByMethod["chart.gettopartists"] = TestDataFactory.makeChartTopArtistsResponseDTO(
			artists: [
				TestDataFactory.makeChartArtistDTO(
					name: "Artist A",
					listeners: "9999",
					mbid: "artist-mbid",
					imageURL: "http://image.test/artist-a.jpg"
				)
			]
		)
		let repository = ChartRepositoryImpl(networkManager: self.mockNetworkManager)

		// when
		let artists = try await repository.fetchTopArtists()

		// then
		#expect(artists.count == 1)
		#expect(artists[0].name == "Artist A")
		#expect(artists[0].listeners == "9999")
		#expect(artists[0].imageURL?.absoluteString == "https://image.test/artist-a.jpg")
		#expect(self.mockNetworkManager.requestedMethods == ["chart.gettopartists"])
	}

	@Test("차트 repository가 네트워크 에러를 그대로 전파하는지 확인")
	mutating func given_네트워크에러가발생할때_fetchTopTracks하면_에러를전파하는지() async {
		// given
		self.mockNetworkManager.errorToThrow = NetworkError.transport(URLError(.notConnectedToInternet))
		let repository = ChartRepositoryImpl(networkManager: self.mockNetworkManager)

		// when
		await #expect(throws: NetworkError.self) {
			_ = try await repository.fetchTopTracks()
		}
	}
}
