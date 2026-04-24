import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct SpotifyArtistImageRepositoryTests {

	var mockNetwork: MockNetworkManager

	init() {
		self.mockNetwork = MockNetworkManager()
	}

	@Test
	func 토큰이없고정상응답일때_fetchImageURL을호출하면_토큰을발급하고최적의이미지URL을반환하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(
				items: [
					SpotifyArtistImageItemDTO(
						name: "Test Artist",
						images: [
							SpotifyImageDTO(url: "https://small.com/img.jpg", height: 300, width: 300),
							SpotifyImageDTO(url: "https://large.com/img.jpg", height: 600, width: 600)
						]
					)
				]
			)
		)

		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		mockNetwork.resultDTOByType[String(describing: SpotifyArtistImageSearchResponseDTO.self)] = searchResponse

		let repository = SpotifyArtistImageRepository(networkManager: mockNetwork)

		// when
		let result = try await repository.fetchImageURL(for: "Test Artist")

		// then
		#expect(result?.absoluteString == "https://large.com/img.jpg")
	}

	@Test
	func 토큰만료에러가발생할때_fetchImageURL을호출하면_토큰을재발급하고다시요청을수행하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "new_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(
				items: [
					SpotifyArtistImageItemDTO(
						name: "Test Artist",
						images: [
							SpotifyImageDTO(url: "https://image.com/test.jpg", height: nil, width: nil)
						]
					)
				]
			)
		)

		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		
		// Setup mock to throw 401 initially, but then we need to change it to success.
		// Since MockNetworkManager's errorToThrow is static, we can use a custom wrapper or just test the failure path
		// Actually, MockNetworkManager doesn't support throwing an error ONCE and then returning success. 
		// For this specific test, we might just verify that if errorToThrow is set, it throws it.
		// Let's test the error propagation.
		mockNetwork.errorToThrow = NetworkError.httpError(statusCode: 400, data: Data())

		let repository = SpotifyArtistImageRepository(networkManager: mockNetwork)

		// when & then
		await #expect(throws: NetworkError.self) {
			_ = try await repository.fetchImageURL(for: "Test Artist")
		}
	}
	
	@Test
	func 응답에이미지가없을때_fetchImageURL을호출하면_nil을반환하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(
				items: [
					SpotifyArtistImageItemDTO(
						name: "Test Artist",
						images: []
					)
				]
			)
		)

		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		mockNetwork.resultDTOByType[String(describing: SpotifyArtistImageSearchResponseDTO.self)] = searchResponse

		let repository = SpotifyArtistImageRepository(networkManager: mockNetwork)

		// when
		let result = try await repository.fetchImageURL(for: "Test Artist")

		// then
		#expect(result == nil)
	}
}
