import Foundation
@testable import MusicSearch

final class MockArtistImageRepository: ArtistImageRepository {
	var imageURLToReturn: URL?
	var errorToThrow: Error?
	var fetchImageURLCallCount = 0
	var receivedArtistName: String?

	func fetchImageURL(for artistName: String) async throws -> URL? {
		self.fetchImageURLCallCount += 1
		self.receivedArtistName = artistName

		if let errorToThrow {
			throw errorToThrow
		}

		return imageURLToReturn
	}
}
