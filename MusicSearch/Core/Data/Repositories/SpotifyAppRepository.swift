//
//  SpotifyAppRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation

actor SpotifyAppRepository: MusicAppRepository {

	private let clientId: String
	private let clientSecret: String
	private var accessToken: String?
	private var accessTokenExpiry: Date?
	private let tokenRefreshLeeway: TimeInterval = 60

	private enum SpotifyRepositoryError: Error {
		case unauthorized
		case invalidURL
		case invalidURI
	}

	init(clientId: String, clientSecret: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
	}

	func fetchDeepLink(for track: Track) async -> URL? {
		let query = "\(track.title) \(track.artist)"
		return await self.searchAndGetURL(query: query, type: "track")
	}

	func fetchDeepLink(for artist: String) async -> URL? {
		return await self.searchAndGetURL(query: artist, type: "artist")
	}

	private func searchAndGetURL(query: String, type: String) async -> URL? {
		do {
			let urlString = try await self.searchWithRetry(query: query, type: type)
			return URL(string: urlString)
		} catch {
			print("SpotifyService Error: \(error)")

			return self.fallbackWebURL(query: query)
		}
	}

	private func searchWithRetry(query: String, type: String) async throws -> String {
		let token = try await self.getAccessToken()
		do {
			return try await self.search(query: query, type: type, token: token)
		} catch SpotifyRepositoryError.unauthorized {
			self.clearToken()
			let refreshedToken = try await self.getAccessToken(forceRefresh: true)
			return try await self.search(query: query, type: type, token: refreshedToken)
		}
	}

	private func getAccessToken(forceRefresh: Bool = false) async throws -> String {
		if !forceRefresh, self.isTokenValid, let token = self.accessToken {
			return token
		}
		if forceRefresh {
			self.clearToken()
		}

		let api = SpotifyAPI.token(clientId: self.clientId, clientSecret: self.clientSecret)
		var request = URLRequest(url: api.url)
		request.httpMethod = api.method
		request.allHTTPHeaderFields = api.headers
		request.httpBody = api.body

		let (data, response) = try await URLSession.shared.data(for: request)

		guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}

		let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
		self.accessToken = tokenResponse.access_token
		self.accessTokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
		return tokenResponse.access_token
	}

	private func search(query: String, type: String, token: String) async throws -> String {
		let api = SpotifyAPI.search(query: query, type: type, token: token)
		var components = URLComponents(url: api.url, resolvingAgainstBaseURL: true)!
		components.queryItems = api.queryItems
		guard let url = components.url else { throw SpotifyRepositoryError.invalidURL }

		var request = URLRequest(url: url)
		request.httpMethod = api.method
		request.allHTTPHeaderFields = api.headers

		let (data, response) = try await URLSession.shared.data(for: request)

		guard let httpResponse = response as? HTTPURLResponse else {
			throw URLError(.badServerResponse)
		}
		if httpResponse.statusCode == 401 {
			throw SpotifyRepositoryError.unauthorized
		}
		guard (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}

		if type == "track" {
			let result = try JSONDecoder().decode(SpotifyTrackSearchResponse.self, from: data)
			guard let item = result.tracks.items.first else { throw URLError(.resourceUnavailable) }
			if let spotifyURL = item.external_urls?.spotify {
				return spotifyURL
			}
			return try self.convertToWebURL(uri: item.uri)
		} else {
			let result = try JSONDecoder().decode(SpotifyArtistSearchResponse.self, from: data)
			guard let item = result.artists.items.first else { throw URLError(.resourceUnavailable) }
			if let spotifyURL = item.external_urls?.spotify {
				return spotifyURL
			}
			return try self.convertToWebURL(uri: item.uri)
		}
	}

	private func convertToWebURL(uri: String) throws -> String {

		let components = uri.components(separatedBy: ":")
		guard components.count == 3 else { throw SpotifyRepositoryError.invalidURI }
		let type = components[1]
		let id = components[2]
		return "https://open.spotify.com/\(type)/\(id)"
	}

	private var isTokenValid: Bool {
		guard let expiry = self.accessTokenExpiry else { return false }
		return Date().addingTimeInterval(self.tokenRefreshLeeway) < expiry
	}

	private func clearToken() {
		self.accessToken = nil
		self.accessTokenExpiry = nil
	}

	private func fallbackWebURL(query: String) -> URL? {
		let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		return URL(string: "https://open.spotify.com/search/\(encodedQuery)")
	}
}
