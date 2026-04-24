import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct SpotifyAppRepositoryTests {

	var mockNetwork: MockNetworkManager

	init() {
		self.mockNetwork = MockNetworkManager()
	}

	@Test
	func 정상적인응답일때_트랙에대한fetchDeepLink를호출하면_Spotify앱URL을반환하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyTrackSearchResponse(
			tracks: SpotifyItems(
				items: [
					SpotifyItem(
						uri: "spotify:track:123",
						external_urls: SpotifyExternalURLs(spotify: "https://open.spotify.com/track/123")
					)
				]
			)
		)

		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		mockNetwork.resultDTOByType[String(describing: SpotifyTrackSearchResponse.self)] = searchResponse

		let repository = SpotifyAppRepository(networkManager: mockNetwork)
		let track = Track(title: "Test Track", artist: "Test Artist", imageURL: nil)

		// when
		let result = await repository.fetchDeepLink(for: track)

		// then
		#expect(result?.absoluteString == "https://open.spotify.com/track/123")
	}

	@Test
	func ExternalURL이없고URI만있을때_아티스트에대한fetchDeepLink를호출하면_웹URL로변환하여반환하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistSearchResponse(
			artists: SpotifyItems(
				items: [
					SpotifyItem(
						uri: "spotify:artist:456",
						external_urls: nil
					)
				]
			)
		)

		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		mockNetwork.resultDTOByType[String(describing: SpotifyArtistSearchResponse.self)] = searchResponse

		let repository = SpotifyAppRepository(networkManager: mockNetwork)

		// when
		let result = await repository.fetchDeepLink(for: "Test Artist")

		// then
		#expect(result?.absoluteString == "https://open.spotify.com/artist/456")
	}

	@Test
	func 네트워크에러발생시_fetchDeepLink를호출하면_검색결과페이지로FallbackURL을반환하는지() async throws {
		// given
		mockNetwork.errorToThrow = NetworkError.transport(URLError(.notConnectedToInternet))

		let repository = SpotifyAppRepository(networkManager: mockNetwork)
		let track = Track(title: "Test", artist: "Artist", imageURL: nil)

		// when
		let result = await repository.fetchDeepLink(for: track)

		// then
		// "Test Artist"를 인코딩하면 "Test%20Artist"
		#expect(result?.absoluteString.contains("https://open.spotify.com/search/") == true)
	}

	@Test
	func 검색중401에러가발생하면_토큰을재발급하고다시요청하는지() async {
		let tokenResponse = SpotifyTokenResponse(access_token: "refreshed-token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyTrackSearchResponse(
			tracks: SpotifyItems(
				items: [
					SpotifyItem(
						uri: "spotify:track:789",
						external_urls: SpotifyExternalURLs(spotify: "https://open.spotify.com/track/789")
					)
				]
			)
		)
		var searchCallCount = 0

		self.mockNetwork.performHandler = { _, responseTypeName in
			switch responseTypeName {
			case String(describing: SpotifyTokenResponse.self):
				return tokenResponse
			case String(describing: SpotifyTrackSearchResponse.self):
				searchCallCount += 1
				if searchCallCount == 1 {
					throw NetworkError.httpError(statusCode: 401, data: Data())
				}
				return searchResponse
			default:
				throw TestDoubleError.missingStubbedValue(responseTypeName)
			}
		}

		let repository = SpotifyAppRepository(networkManager: self.mockNetwork)
		let track = Track(title: "Retry Track", artist: "Retry Artist", imageURL: nil)

		let result = await repository.fetchDeepLink(for: track)

		#expect(result?.absoluteString == "https://open.spotify.com/track/789")
		#expect(searchCallCount == 2)
	}
}
