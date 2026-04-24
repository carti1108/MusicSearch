import Testing
import Foundation
@testable import MusicSearch

private final class MockArtistImageEnrichmentService: ArtistImageEnrichmentService {
	var enrichCallCount = 0
	var receivedArtists: [[Artist]] = []
	var result: [Artist] = []

	func enrich(_ artists: [Artist]) async -> [Artist] {
		self.enrichCallCount += 1
		self.receivedArtists.append(artists)
		return self.result
	}
}

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

	@Test
	mutating func enrichmentService가주어질때_execute하면_보강결과를반환하는지() async throws {
		let fetchedArtists = [
			TestDataFactory.makeArtist(name: "Artist A"),
			TestDataFactory.makeArtist(name: "Artist B")
		]
		let enrichedArtists = [
			TestDataFactory.makeArtist(name: "Artist A", imageURL: "https://image.test/a.jpg"),
			TestDataFactory.makeArtist(name: "Artist B", imageURL: "https://image.test/b.jpg")
		]
		let enrichmentService = MockArtistImageEnrichmentService()
		enrichmentService.result = enrichedArtists
		self.mockChartRepository.fetchTopArtistsResult = .success(fetchedArtists)
		let useCase = FetchChartTopArtistsUseCaseImpl(
			chartRepository: self.mockChartRepository,
			artistImageEnrichmentService: enrichmentService
		)

		let artists = try await useCase.execute()

		#expect(artists == enrichedArtists)
		#expect(enrichmentService.enrichCallCount == 1)
		#expect(enrichmentService.receivedArtists == [fetchedArtists])
	}
}
