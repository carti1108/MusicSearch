//
//  TrackRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation
import OSLog
import MSData
import MSDomain
import MSUtil
import NetworkLayer
import TrackSearchDomain

public struct TrackRepositoryImpl: TrackRepository {

	private let networkManager: NetworkRequesting

	public init(networkManager: NetworkRequesting) {
		self.networkManager = networkManager
	}

	public func searchTracks(
		query: String,
		limit: Int,
		offset: Int
	) async throws -> (tracks: [Track], totalResults: Int) {
		let page = (limit > 0) ? (offset / limit) + 1 : 1
		return self.makeSearchResult(from: try await self.networkManager.perform(
			with: LastFMAPI.searchTracks(keyword: query, limit: limit, page: page),
			as: TrackSearchResponseDTO.self
		))
	}

	public func fetchTopTracks(by tag: String) async throws -> [Track] {
		let response: TagTopTracksResponseDTO = try await self.networkManager.perform(
			with: LastFMAPI.fetchTopTracks(tag: tag),
			as: TagTopTracksResponseDTO.self
		)
		return response.tracks.track.map { $0.toDomain() }
	}

	public func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		let response: TrackSimilarResponseDTO = try await self.networkManager.perform(
			with: LastFMAPI.fetchSimilarTracks(track: track),
			as: TrackSimilarResponseDTO.self
		)
		return response.similartracks.track.map { $0.toDomain() }
	}

	public func fetchTrackInfo(for track: Track) async throws -> Track {
		if track.thumbnailURL != nil {
			return track
		}

		do {
			let response: TrackInfoResponseDTO = try await self.networkManager.perform(
				with: LastFMAPI.getTrackInfo(track: track),
				as: TrackInfoResponseDTO.self
			)
			return self.merge(track: track, with: response)
		} catch {
			Logger(subsystem: "MusicSearch", category: "TrackRepository")
				.error("Track info fetch failed: \(error.localizedDescription). Returning original track.")
			return track
		}
	}

	private func makeSearchResult(
		from response: TrackSearchResponseDTO
	) -> (tracks: [Track], totalResults: Int) {
		(
			tracks: response.results.trackmatches.track.map { $0.toDomain() },
			totalResults: Int(response.results.totalResults) ?? 0
		)
	}

	private func merge(track: Track, with response: TrackInfoResponseDTO) -> Track {
		let imageURL = response.track.album?
			.image
			.flatMap(self.makeImageURL(from:))

		return Track(
			id: track.id,
			mbid: track.mbid,
			title: track.title,
			artist: track.artist,
			imageURL: imageURL
		)
	}

	private func makeImageURL(from images: [LastFMImageDTO]) -> URL? {
		let imageString = images.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
			?? images.first { !$0.text.isEmpty }?.text

		guard let imageString,
			  let url = URL(string: imageString) else {
			return nil
		}

		if imageString.contains("2a96cbd8b46e442fc41c2b86b821562f") {
			return nil
		}

		return url.forcedHTTPS
	}
}
