import Foundation
@testable import MusicSearch

final class MockFetchArtistImageURLUseCase: FetchArtistImageURLUseCase {
	var resultURL: URL?
	var errorToThrow: Error?
	var executeCallCount = 0
	var receivedArtistName: String?
	
	var executeHandler: ((String) async throws -> URL?)?

	func execute(artistName: String) async throws -> URL? {
		self.executeCallCount += 1
		self.receivedArtistName = artistName

		if let executeHandler {
			return try await executeHandler(artistName)
		}

		if let errorToThrow {
			throw errorToThrow
		}

		return resultURL
	}
}
