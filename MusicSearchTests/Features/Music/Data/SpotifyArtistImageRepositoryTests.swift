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
	func 네트워크에러가발생할때_fetchImageURL을호출하면_에러를던지는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		mockNetwork.errorToThrow = NetworkError.httpError(statusCode: 400, data: Data())
		let repository = SpotifyArtistImageRepository(networkManager: mockNetwork)

		// when
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
					SpotifyArtistImageItemDTO(name: "Test Artist", images: [])
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

	@Test
	func width가nil인이미지만있을때_fetchImageURL을호출하면_이미지URL을반환하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(
				items: [
					SpotifyArtistImageItemDTO(
						name: "Test Artist",
						images: [
							SpotifyImageDTO(url: "https://img.com/first.jpg", height: nil, width: nil),
							SpotifyImageDTO(url: "https://img.com/second.jpg", height: nil, width: nil)
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
		#expect(result != nil)
	}

	@Test
	func 아티스트검색결과가비어있을때_fetchImageURL을호출하면_nil을반환하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(items: [])
		)
		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		mockNetwork.resultDTOByType[String(describing: SpotifyArtistImageSearchResponseDTO.self)] = searchResponse
		let repository = SpotifyArtistImageRepository(networkManager: mockNetwork)

		// when
		let result = try await repository.fetchImageURL(for: "Unknown Artist")

		// then
		#expect(result == nil)
	}

	@Test
	func 이미지URL이http일때_fetchImageURL을호출하면_https로변환하여반환하는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "test_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(
				items: [
					SpotifyArtistImageItemDTO(
						name: "Test Artist",
						images: [
							SpotifyImageDTO(url: "http://img.com/artist.jpg", height: 500, width: 500)
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
		#expect(result?.scheme == "https")
		#expect(result?.absoluteString == "https://img.com/artist.jpg")
	}

	@Test
	func 유효한토큰이이미있을때_두번째fetchImageURL을호출하면_토큰을재발급하지않는지() async throws {
		// given
		let tokenResponse = SpotifyTokenResponse(access_token: "cached_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(
				items: [
					SpotifyArtistImageItemDTO(
						name: "Test Artist",
						images: [SpotifyImageDTO(url: "https://img.com/artist.jpg", height: 300, width: 300)]
					)
				]
			)
		)
		mockNetwork.resultDTOByType[String(describing: SpotifyTokenResponse.self)] = tokenResponse
		mockNetwork.resultDTOByType[String(describing: SpotifyArtistImageSearchResponseDTO.self)] = searchResponse
		let repository = SpotifyArtistImageRepository(networkManager: mockNetwork)

		// when
		_ = try await repository.fetchImageURL(for: "Test Artist")
		_ = try await repository.fetchImageURL(for: "Test Artist")

		// then
		#expect(mockNetwork.typeCallCounts[String(describing: SpotifyTokenResponse.self)] == 1)
	}

	@Test
	func 검색시401에러가발생할때_fetchImageURL을호출하면_토큰재발급후재시도하는지() async throws {
		// given
		let mockSeq = MockSequentialNetworkManager()
		let tokenResponse = SpotifyTokenResponse(access_token: "first_token", token_type: "Bearer", expires_in: 3600)
		let newTokenResponse = SpotifyTokenResponse(access_token: "refreshed_token", token_type: "Bearer", expires_in: 3600)
		let searchResponse = SpotifyArtistImageSearchResponseDTO(
			artists: SpotifyArtistImageItemsDTO(
				items: [
					SpotifyArtistImageItemDTO(
						name: "Test Artist",
						images: [SpotifyImageDTO(url: "https://img.com/artist.jpg", height: 300, width: 300)]
					)
				]
			)
		)
		mockSeq.enqueue(tokenResponse, forType: SpotifyTokenResponse.self)
		mockSeq.enqueueError(
			NetworkError.httpError(statusCode: 401, data: Data()),
			forType: String(describing: SpotifyArtistImageSearchResponseDTO.self)
		)
		mockSeq.enqueue(newTokenResponse, forType: SpotifyTokenResponse.self)
		mockSeq.enqueue(searchResponse, forType: SpotifyArtistImageSearchResponseDTO.self)
		let repository = SpotifyArtistImageRepository(networkManager: mockSeq)

		// when
		let result = try await repository.fetchImageURL(for: "Test Artist")

		// then
		#expect(result?.absoluteString == "https://img.com/artist.jpg")
		#expect(mockSeq.callCount(for: SpotifyTokenResponse.self) == 2)
	}
}
