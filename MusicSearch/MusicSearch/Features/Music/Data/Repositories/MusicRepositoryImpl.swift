//
//  MusicRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
import NetworkLayer

final class MusicRepositoryImpl: MusicRepository {

	private let networkManager: NetworkRequesting

	init(networkManager: NetworkRequesting) {
		self.networkManager = networkManager
	}

	func searchTracks(query: String) async throws -> [Track] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.searchTracks(keyword: query),
			as: TrackSearchResponseDTO.self
		)

		return response.results.trackmatches.track.map { $0.toDomain() }
	}

	func fetchTopTracks(by tag: String) async throws -> [Track] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.fetchTopTracks(tag: tag),
			as: TagTopTracksResponseDTO.self
		)
		
		var tracks = response.tracks.track.map { $0.toDomain() }
		tracks = await self.updateTracksWithAlbumArt(tracks)
		
		return tracks
	}
	
	private func updateTracksWithAlbumArt(_ tracks: [Track]) async -> [Track] {
		var updatedTracks = tracks
		
		await withTaskGroup(of: (Int, Track?).self) { group in
			for (index, track) in tracks.enumerated() {
				group.addTask { [weak self] in
					guard let self = self else { return (index, nil) }
					return (index, await self.fetchAlbumArtForTrack(track))
				}
			}
			
			for await (index, trackWithAlbumArt) in group {
				if let trackWithAlbumArt = trackWithAlbumArt {
					updatedTracks[index] = trackWithAlbumArt
				}
			}
		}
		
		return updatedTracks
	}
	
	private func fetchAlbumArtForTrack(_ track: Track) async -> Track? {
		do {
			let trackInfoResponse = try await self.networkManager.request(
				with: LastFMAPI.getTrackInfo(track: track),
				as: TrackInfoResponseDTO.self
			)
			
			guard let album = trackInfoResponse.track.album,
				  let images = album.image else {
				return nil
			}
			
			let imageString = images.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
						   ?? images.first { !$0.text.isEmpty }?.text
			
			guard let imageString = imageString,
				  let imageURL = URL(string: imageString) else {
				return nil
			}
			
			return Track(
				id: track.id,
				title: track.title,
				artist: track.artist,
				imageURL: imageURL
			)
		} catch {
			return nil
		}
	}

	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.fetchSimilarTracks(track: track),
			as: TrackSimilarResponseDTO.self
		)
		return response.similartracks.track.map { $0.toDomain() }
	}

	func searchArtists(query: String) async throws -> [Artist] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.searchArtists(keyword: query),
			as: ArtistSearchResponseDTO.self
		)
		return response.results.artistmatches.artist.map { $0.toDomain() }
	}

	func fetchAlbums(for artist: Artist) async throws -> [Album] {
		let response = try await self.networkManager.request(
			with: LastFMAPI.fetchArtistAlbums(artist: artist),
			as: ArtistTopAlbumsResponseDTO.self
		)
		return response.topalbums.album.map { $0.toDomain() }
	}
}
