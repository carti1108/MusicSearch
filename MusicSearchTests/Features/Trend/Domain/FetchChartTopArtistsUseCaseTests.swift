import Testing
import Foundation
@testable import MusicSearch

struct FetchChartTopArtistsUseCaseTests {
	var mockChartRepository: MockChartRepository

	init() {
		self.mockChartRepository = MockChartRepository()
	}

	@Test
	mutating func 아티스트차트조회결과가있을때_execute하면_그대로반환하는지() async throws {
		// given
		let expectedArtists = [
			TestDataFactory.makeArtist(name: "Artist A", listeners: "1000"),
			TestDataFactory.makeArtist(name: "Artist B", listeners: "2000")
		]
		self.mockChartRepository.fetchTopArtistsResult = .success(expectedArtists)
		let useCase = FetchChartTopArtistsUseCaseImpl(chartRepository: self.mockChartRepository)

		// when
		let artists = try await useCase.execute()

		// then
		#expect(artists == expectedArtists)
		#expect(self.mockChartRepository.fetchTopArtistsCallCount == 1)
	}

	@Test
	mutating func repository에서에러가발생할때_execute하면_에러를전파하는지() async {
		// given
		enum TestError: Error {
			case failed
		}

		self.mockChartRepository.fetchTopArtistsResult = .failure(TestError.failed)
		let useCase = FetchChartTopArtistsUseCaseImpl(chartRepository: self.mockChartRepository)

		// when
		await #expect(throws: TestError.self) {
			try await useCase.execute()
		}

		// then
		#expect(self.mockChartRepository.fetchTopArtistsCallCount == 1)
	}
}
