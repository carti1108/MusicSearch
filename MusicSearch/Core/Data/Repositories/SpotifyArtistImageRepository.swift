//
//  SpotifyArtistImageRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation

actor SpotifyArtistImageRepository: ArtistImageRepository {

	private let clientId: String
	private let clientSecret: String
	private var accessToken: String?
	private var accessTokenExpiry: Date?
	private let tokenRefreshLeeway: TimeInterval = 60

	private enum SpotifyRepositoryError: Error {
		case invalidURL
		case unauthorized
	}

	init(
		clientId: String,
		clientSecret: String
	) {
		self.clientId = clientId
		self.clientSecret = clientSecret
	}

	func fetchImageURL(for artistName: String) async throws -> URL? {
		let token = try await self.getAccessToken()

		do {
			return try await self.fetchImageURL(artistName: artistName, token: token)
		} catch SpotifyRepositoryError.unauthorized {
			self.clearToken()
			let refreshedToken = try await self.getAccessToken(isRefresh: true)
			return try await self.fetchImageURL(artistName: artistName, token: refreshedToken)
		}
	}

	private func getAccessToken(isRefresh: Bool = false) async throws -> String {
		if !isRefresh, self.isTokenValid, let token = self.accessToken {
			return token
		}
		if isRefresh {
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

	private func fetchImageURL(artistName: String, token: String) async throws -> URL? {
		let api = SpotifyAPI.artistSearch(
			query: self.artistSearchQuery(for: artistName),
			token: token,
			limit: 1
		)
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

		let response = try JSONDecoder().decode(SpotifyArtistImageSearchResponseDTO.self, from: data)

		return self.bestArtistImageURL(from: response.artists.items)
	}

	private func artistSearchQuery(for artistName: String) -> String {
		let sanitizedName = artistName.replacingOccurrences(of: "\"", with: "")
		return sanitizedName
	}

	private func bestArtistImageURL(from items: [SpotifyArtistImageItemDTO]) -> URL? {
		guard let selectedArtist = items.first else { return nil }
		return self.bestImageURL(from: selectedArtist.images)
	}

	private func bestImageURL(from images: [SpotifyImageDTO]) -> URL? {
		let selectedImage = images.max { lhs, rhs in
			(lhs.width ?? 0) < (rhs.width ?? 0)
		}

		return selectedImage
			.flatMap { URL(string: $0.url) }?
			.secureURL
	}

	private var isTokenValid: Bool {
		guard let expiry = self.accessTokenExpiry else { return false }
		return Date().addingTimeInterval(self.tokenRefreshLeeway) < expiry
	}

	private func clearToken() {
		self.accessToken = nil
		self.accessTokenExpiry = nil
	}
}
