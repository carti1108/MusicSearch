//
//  SpotifyArtistImageRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation
import NetworkLayer

actor SpotifyArtistImageRepository: ArtistImageRepository {

	private var accessToken: String?
	private var accessTokenExpiry: Date?
	private let configuration: SpotifyAPIConfiguration
	private let networkManager: NetworkRequesting

	private enum SpotifyRepositoryError: Error {
		case invalidURL
		case unauthorized
	}

	init(
		configuration: SpotifyAPIConfiguration = DefaultSpotifyAPIConfiguration(),
		networkManager: NetworkRequesting
	) {
		self.configuration = configuration
		self.networkManager = networkManager
	}

	func fetchImageURL(for artistName: String) async throws -> URL? {
		let token = try await self.getAccessToken()

		do {
			return try await self.fetchImageURL(artistName: artistName, token: token)
		} catch SpotifyRepositoryError.unauthorized {
			self.clearToken()
			let refreshedToken = try await self.getAccessToken(isRefresh: true)
			return try await self.fetchImageURL(artistName: artistName, token: refreshedToken)
		} catch let error as NetworkLayer.NetworkError {
			if case .httpError(let code, _) = error, code == 401 {
				self.clearToken()
				let refreshedToken = try await self.getAccessToken(isRefresh: true)
				return try await self.fetchImageURL(artistName: artistName, token: refreshedToken)
			}
			throw error
		}
	}

	private func getAccessToken(isRefresh: Bool = false) async throws -> String {
		if !isRefresh, self.isTokenValid, let token = self.accessToken {
			return token
		}
		if isRefresh {
			self.clearToken()
		}

		let api = SpotifyAPI.token(config: self.configuration)
		let tokenResponse = try await self.networkManager.perform(with: api, as: SpotifyTokenResponse.self)

		self.accessToken = tokenResponse.access_token
		self.accessTokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
		return tokenResponse.access_token
	}

	private func fetchImageURL(artistName: String, token: String) async throws -> URL? {
		let api = SpotifyAPI.artistSearch(
			query: self.artistSearchQuery(for: artistName),
			token: token,
			limit: 1,
			config: self.configuration
		)
		let searchResponse = try await self.networkManager.perform(
			with: api,
			as: SpotifyArtistImageSearchResponseDTO.self
		)

		return self.bestArtistImageURL(from: searchResponse.artists.items)
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

		guard let selectedImage,
			  let url = URL(string: selectedImage.url) else {
			return nil
		}
		return url.forcedHTTPS
	}

	private var isTokenValid: Bool {
		guard let expiry = self.accessTokenExpiry else { return false }
		return Date().addingTimeInterval(self.configuration.tokenRefreshLeeway) < expiry
	}

	private func clearToken() {
		self.accessToken = nil
		self.accessTokenExpiry = nil
	}
}
