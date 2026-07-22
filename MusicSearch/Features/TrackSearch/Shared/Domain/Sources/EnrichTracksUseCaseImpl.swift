//
//  EnrichTracksUseCaseImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 7/21/26.
//

import Foundation
import MSDomain
import OSLog

public protocol EnrichTracksUseCase: Sendable {
	func execute(tracks: [Track]) async -> [Track]
}

public struct EnrichTracksUseCaseImpl: EnrichTracksUseCase {
	private let trackRepository: TrackRepository
	private let musicAppService: MusicAppService?
	private let maxConcurrentInfoRequests: Int

	public init(
		trackRepository: TrackRepository,
		musicAppService: MusicAppService? = nil,
		maxConcurrentInfoRequests: Int = 8
	) {
		self.trackRepository = trackRepository
		self.musicAppService = musicAppService
		self.maxConcurrentInfoRequests = maxConcurrentInfoRequests
	}

	public func execute(tracks: [Track]) async -> [Track] {
		await tracks.enrichingTrackInfo(maxConcurrentRequests: self.maxConcurrentInfoRequests) { track in
			if track.thumbnailURL != nil {
				return track
			}

			if let musicAppService = self.musicAppService {
				let sanitizedTitle = track.title.replacingOccurrences(of: "\"", with: "")
				let sanitizedArtist = track.artist.replacingOccurrences(of: "\"", with: "")
				var query = "track:\"\(sanitizedTitle)\" artist:\"\(sanitizedArtist)\""

				if let albumTitle = track.albumTitle {
					let sanitizedAlbum = albumTitle.replacingOccurrences(of: "\"", with: "")
					query += " album:\"\(sanitizedAlbum)\""
				}

				do {
					let result = try await musicAppService.searchTracks(query: query, limit: 1, offset: 0)
					if let spotifyTrack = result.tracks.first {
						return Track(
							id: track.id,
							mbid: track.mbid,
							title: track.title,
							artist: track.artist,
							imageURL: spotifyTrack.imageURL,
							thumbnailURL: spotifyTrack.thumbnailURL,
							albumTitle: spotifyTrack.albumTitle ?? track.albumTitle,
							albumType: spotifyTrack.albumType ?? track.albumType,
							releaseDate: spotifyTrack.releaseDate ?? track.releaseDate
						)
					}
				} catch {
					Logger(subsystem: "MusicSearch", category: "EnrichTracksUseCase")
						.error("Spotify App track info search failed: \(error.localizedDescription).")
				}
			}

			do {
				return try await self.trackRepository.fetchTrackInfo(for: track)
			} catch {
				Logger(subsystem: "MusicSearch", category: "EnrichTracksUseCase")
					.error("Track info fetch failed: \(error.localizedDescription). Returning original track.")
				return track
			}
		}
	}
}
