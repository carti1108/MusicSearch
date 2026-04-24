import Testing
import Foundation
@testable import MusicSearch

struct ArtistImageEnrichmentServiceTests {

	@Test
	func 다수의아티스트가주어졌을때_enrich를호출하면_동시성을활용해모든이미지를가져와병합하는지() async throws {
		// given
		let mockUseCase = MockFetchArtistImageURLUseCase()
		mockUseCase.executeHandler = { name in
			return URL(string: "https://image.com/\(name).jpg")
		}

		let service = ArtistImageEnrichmentServiceImpl(fetchArtistImageURLUseCase: mockUseCase, maxConcurrentImageRequests: 2)

		let artists = [
			Artist(id: "1", name: "A", imageURL: nil, listeners: nil, tags: [], bio: nil),
			Artist(id: "2", name: "B", imageURL: nil, listeners: nil, tags: [], bio: nil),
			Artist(id: "3", name: "C", imageURL: nil, listeners: nil, tags: [], bio: nil)
		]

		// when
		let result = await service.enrich(artists)

		// then
		#expect(result.count == 3)
		#expect(result.first(where: { $0.id == "1" })?.imageURL?.absoluteString == "https://image.com/A.jpg")
		#expect(result.first(where: { $0.id == "2" })?.imageURL?.absoluteString == "https://image.com/B.jpg")
		#expect(result.first(where: { $0.id == "3" })?.imageURL?.absoluteString == "https://image.com/C.jpg")
		#expect(mockUseCase.executeCallCount == 3)
	}

	@Test
	func 일부아티스트조회가실패할때_enrich를호출하면_실패한데이터는원본을유지하고성공한데이터만병합하는지() async throws {
		// given
		enum TestError: Error { case failed }
		
		let mockUseCase = MockFetchArtistImageURLUseCase()
		mockUseCase.executeHandler = { name in
			if name == "FailArtist" {
				throw TestError.failed
			}
			return URL(string: "https://image.com/\(name).jpg")
		}

		let service = ArtistImageEnrichmentServiceImpl(fetchArtistImageURLUseCase: mockUseCase, maxConcurrentImageRequests: 2)

		let originalURL = URL(string: "https://original.com/old.jpg")
		let artists = [
			Artist(id: "1", name: "SuccessArtist", imageURL: nil, listeners: nil, tags: [], bio: nil),
			Artist(id: "2", name: "FailArtist", imageURL: originalURL, listeners: nil, tags: [], bio: nil)
		]

		// when
		let result = await service.enrich(artists)

		// then
		#expect(result.count == 2)
		#expect(result.first(where: { $0.id == "1" })?.imageURL?.absoluteString == "https://image.com/SuccessArtist.jpg")
		#expect(result.first(where: { $0.id == "2" })?.imageURL == originalURL) // 실패 시 원본 유지
	}
}
