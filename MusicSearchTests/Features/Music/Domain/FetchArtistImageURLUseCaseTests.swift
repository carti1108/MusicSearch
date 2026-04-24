import Testing
import Foundation
@testable import MusicSearch

struct FetchArtistImageURLUseCaseTests {

	@Test
	func 정상적인응답일때_아티스트이름으로execute를호출하면_URL을반환하는지() async throws {
		// given
		let mockRepository = MockArtistImageRepository()
		let expectedURL = URL(string: "https://image.com/test.jpg")
		mockRepository.imageURLToReturn = expectedURL

		let useCase = FetchArtistImageURLUseCaseImpl(artistImageRepository: mockRepository)

		// when
		let result = try await useCase.execute(artistName: "Test Artist")

		// then
		#expect(result == expectedURL)
		#expect(mockRepository.fetchImageURLCallCount == 1)
		#expect(mockRepository.receivedArtistName == "Test Artist")
	}

	@Test
	func 레포지토리에서에러가발생할때_execute를호출하면_에러를던지는지() async throws {
		// given
		let mockRepository = MockArtistImageRepository()
		mockRepository.errorToThrow = URLError(.notConnectedToInternet)

		let useCase = FetchArtistImageURLUseCaseImpl(artistImageRepository: mockRepository)

		// when & then
		await #expect(throws: URLError.self) {
			_ = try await useCase.execute(artistName: "Test Artist")
		}
	}
}
