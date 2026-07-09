import MSDomain
import Foundation

public struct SpotifySearchTracksUseCaseImpl: SearchTracksUseCase {

	private let spotifyRepository: MusicAppService

	public init(spotifyRepository: MusicAppService) {
		self.spotifyRepository = spotifyRepository
	}

	public func execute(
		query: String,
		limit: Int,
		page: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !normalizedQuery.isEmpty else {
			return ([], 0)
		}

		let offset = max(0, (page - 1) * limit)

		return try await self.spotifyRepository.searchSpotifyTracks(
			query: normalizedQuery,
			limit: limit,
			offset: offset
		)
	}
}
