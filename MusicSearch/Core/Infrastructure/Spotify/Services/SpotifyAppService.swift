//
//  SpotifyAppService.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation
import NetworkLayer
import MSDomain
import OSLog

public actor SpotifyAppService: MusicAppService {

	private struct SearchRequest {
		let query: String
		let type: String
	}

	private let configuration: SpotifyAPIConfiguration
	private let networkManager: NetworkRequesting
	private let authService: MusicAuthService

	private enum SpotifyRepositoryError: Error {
		case unauthorized
		case invalidURL
		case invalidURI
	}

	public init(
		configuration: SpotifyAPIConfiguration = DefaultSpotifyAPIConfiguration(),
		networkManager: NetworkRequesting,
		authService: MusicAuthService
	) {
		self.configuration = configuration
		self.networkManager = networkManager
		self.authService = authService
	}

	public func fetchDeepLink(for track: Track) async -> URL? {
		let query = "\(track.title) \(track.artist)"
		return await self.searchAndGetURL(query: query, type: "track")
	}

	public func fetchDeepLink(for artist: String) async -> URL? {
		return await self.searchAndGetURL(query: artist, type: "artist")
	}

	private func searchAndGetURL(query: String, type: String) async -> URL? {
		do {
			let request = SearchRequest(query: query, type: type)
			let urlString = try await self.searchWithRetry(query: request.query, type: request.type)
			return try self.makeURL(from: urlString)
		} catch {
			Logger(subsystem: "MusicSearch", category: "SpotifyAppService")
				.error("fetchAppRedirectURL failed: \(error.localizedDescription). Returning fallback Web URL.")
			return self.fallbackWebURL(query: query)
		}
	}

	private func searchWithRetry(query: String, type: String) async throws -> String {
		let token = try await self.getAccessToken()
		return try await self.search(query: query, type: type, token: token)
	}

	public func searchSpotifyTracks(query: String, limit: Int, offset: Int) async throws -> (tracks: [Track], totalResults: Int) {
		let token = try await self.getAccessToken()
		return try await self.performSearchSpotifyTracks(query: query, limit: limit, offset: offset, token: token)
	}

	private func performSearchSpotifyTracks(query: String, limit: Int, offset: Int, token: String) async throws -> (tracks: [Track], totalResults: Int) {
		let api = SpotifyAPI.search(query: query, type: "track", limit: limit, offset: offset, token: token, config: self.configuration)
		let result = try await self.networkManager.perform(with: api, as: SpotifyTrackSearchResponse.self)

		let tracks = result.tracks.items.map { $0.toDomain() }
		return (tracks: tracks, totalResults: result.tracks.total ?? 0)
	}

	private func getAccessToken() async throws -> String {
		if let token = authService.getAccessToken() {
			return token
		}

		do {
			return try await authService.getClientCredentialsToken()
		} catch {
			throw SpotifyRepositoryError.unauthorized
		}
	}

	private func search(query: String, type: String, token: String) async throws -> String {
		let api = SpotifyAPI.search(query: query, type: type, limit: 1, offset: 0, token: token, config: self.configuration)

		if type == "track" {
			let result = try await self.networkManager.perform(with: api, as: SpotifyTrackSearchResponse.self)
			guard let item = result.tracks.items.first else { throw URLError(.resourceUnavailable) }
			if let spotifyURL = item.external_urls?.spotify {
				return spotifyURL
			}
			return try self.convertToWebURL(uri: item.uri)
		} else {
			let result = try await self.networkManager.perform(with: api, as: SpotifyArtistSearchResponse.self)
			guard let item = result.artists.items.first else { throw URLError(.resourceUnavailable) }
			if let spotifyURL = item.external_urls?.spotify {
				return spotifyURL
			}
			guard let uri = item.uri else { throw URLError(.resourceUnavailable) }
			return try self.convertToWebURL(uri: uri)
		}
	}

	private func convertToWebURL(uri: String) throws -> String {
		let components = uri.components(separatedBy: ":")
		guard components.count == 3 else { throw SpotifyRepositoryError.invalidURI }
		let type = components[1]
		let id = components[2]
		return "https://open.spotify.com/\(type)/\(id)"
	}

	private func makeURL(from urlString: String) throws -> URL {
		guard let url = URL(string: urlString) else {
			throw SpotifyRepositoryError.invalidURL
		}
		return url
	}

	private func fallbackWebURL(query: String) -> URL? {
		let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		return URL(string: "https://open.spotify.com/search/\(encodedQuery)")
	}
}
