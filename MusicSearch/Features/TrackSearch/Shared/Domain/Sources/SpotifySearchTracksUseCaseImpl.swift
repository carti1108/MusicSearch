import MSDomain
import Foundation

public struct SpotifySearchTracksUseCaseImpl: SearchTracksUseCase {

	private let spotifyRepository: MusicAppRepository

	public init(spotifyRepository: MusicAppRepository) {
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

		// Calculate offset from page
		// Spotify uses offset = (page - 1) * limit
		let offset = max(0, (page - 1) * limit)

		return try await self.spotifyRepository.searchSpotifyTracks(
			query: normalizedQuery,
			limit: limit,
			offset: offset
		)
	}
}
