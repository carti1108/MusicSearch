import Foundation
import Testing
@testable import MusicSearch

@MainActor
struct AppComponentTests {
	@Test
	func musicAppRepository와artistImageRepository를여러번조회해도_같은인스턴스를재사용하는지() {
		let component = AppComponent(
			networkManager: MockNetworkManager(),
			locationManager: MockLocationManager()
		)

		let firstMusicRepository = component.musicAppRepository as AnyObject
		let secondMusicRepository = component.musicAppRepository as AnyObject
		let firstArtistRepository = component.artistImageRepository as AnyObject
		let secondArtistRepository = component.artistImageRepository as AnyObject

		#expect(firstMusicRepository === secondMusicRepository)
		#expect(firstArtistRepository === secondArtistRepository)
	}

	@Test
	func fetchMusicAppDeepLinkUseCase와fetchArtistImageURLUseCase를여러번조회해도_같은인스턴스를재사용하는지() {
		let component = AppComponent(
			networkManager: MockNetworkManager(),
			locationManager: MockLocationManager()
		)

		let firstDeepLinkUseCase = component.fetchMusicAppDeepLinkUseCase as AnyObject
		let secondDeepLinkUseCase = component.fetchMusicAppDeepLinkUseCase as AnyObject
		let firstImageUseCase = component.fetchArtistImageURLUseCase as AnyObject
		let secondImageUseCase = component.fetchArtistImageURLUseCase as AnyObject

		#expect(firstDeepLinkUseCase === secondDeepLinkUseCase)
		#expect(firstImageUseCase === secondImageUseCase)
	}

	@Test
	func fetchChartTopTracksUseCase가_AppComponent배선대로차트와상세정보를조합하는지() async throws {
		let mockNetwork = MockNetworkManager()
		mockNetwork.resultDTOByMethod["chart.gettoptracks"] = TestDataFactory.makeChartTopTracksResponseDTO(
			tracks: [
				TestDataFactory.makeChartTrackDTO(name: "Track A", artist: "Artist A", mbid: "track-a"),
				TestDataFactory.makeChartTrackDTO(name: "Track B", artist: "Artist B", mbid: "track-b"),
				TestDataFactory.makeChartTrackDTO(name: "Track C", artist: "Artist C", mbid: "track-c")
			]
		)
		mockNetwork.resultDTOByMethod["track.getInfo"] = TrackInfoResponseDTO(
			track: LastFMTrackInfoDTO(
				name: "Enriched Track",
				artist: LastFMArtistNameDTO(name: "Artist A", mbid: nil, url: "https://test.com"),
				album: LastFMAlbumInfoDTO(
					title: "Album",
					image: [LastFMImageDTO(size: "extralarge", text: "https://image.test/enriched.jpg")]
				)
			)
		)

		let component = AppComponent(
			networkManager: mockNetwork,
			locationManager: MockLocationManager()
		)

		let tracks = try await component.fetchChartTopTracksUseCase.execute()

		#expect(tracks.count == 3)
		#expect(tracks.allSatisfy { $0.imageURL?.absoluteString == "https://image.test/enriched.jpg" })
		#expect(mockNetwork.requestedMethods.first == "chart.gettoptracks")
		#expect(mockNetwork.requestedMethods.filter { $0 == "track.getInfo" }.count == 3)
	}

	@Test
	func fetchChartTopArtistsUseCase가_AppComponent배선대로아티스트이미지보강까지수행하는지() async throws {
		let mockNetwork = MockNetworkManager()
		mockNetwork.resultDTOByMethod["chart.gettopartists"] = TestDataFactory.makeChartTopArtistsResponseDTO(
			artists: [
				TestDataFactory.makeChartArtistDTO(name: "Artist A", listeners: "111"),
				TestDataFactory.makeChartArtistDTO(name: "Artist B", listeners: "222"),
				TestDataFactory.makeChartArtistDTO(name: "Artist C", listeners: "333")
			]
		)

		mockNetwork.performHandler = { requestable, responseTypeName in
			if responseTypeName == String(describing: SpotifyTokenResponse.self) {
				return SpotifyTokenResponse(access_token: "spotify-token", token_type: "Bearer", expires_in: 3600)
			}

			if responseTypeName == String(describing: SpotifyArtistImageSearchResponseDTO.self) {
				guard case let .requestParameters(parameters, _) = requestable.task,
					  let query = parameters["q"] as? String else {
					throw TestDoubleError.missingStubbedValue("Spotify artist query")
				}

				return SpotifyArtistImageSearchResponseDTO(
					artists: SpotifyArtistImageItemsDTO(
						items: [
							SpotifyArtistImageItemDTO(
								name: query,
								images: [
									SpotifyImageDTO(
										url: "https://image.test/\(query).jpg",
										height: 500,
										width: 500
									)
								]
							)
						]
					)
				)
			}

			throw TestDoubleError.missingStubbedValue(responseTypeName)
		}

		let component = AppComponent(
			networkManager: mockNetwork,
			locationManager: MockLocationManager()
		)

		let artists = try await component.fetchChartTopArtistsUseCase.execute()

		#expect(artists.count == 3)
		#expect(artists[0].imageURL?.absoluteString == "https://image.test/Artist%20A.jpg")
		#expect(artists[1].imageURL?.absoluteString == "https://image.test/Artist%20B.jpg")
		#expect(artists[2].imageURL?.absoluteString == "https://image.test/Artist%20C.jpg")
		#expect(mockNetwork.requestedMethods.contains("chart.gettopartists"))
	}
}
