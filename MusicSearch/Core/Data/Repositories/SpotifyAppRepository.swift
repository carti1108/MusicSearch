//
//  SpotifyAppRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation
import NetworkLayer
import MSDomain

public actor SpotifyAppRepository: MusicAppRepository {

	private struct SearchRequest {
		let query: String
		let type: String
	}

	private var accessToken: String?
	private var accessTokenExpiry: Date?
	private var accessTokenRequest: (id: UUID, task: Task<SpotifyTokenResponse, Error>)?
	private let configuration: SpotifyAPIConfiguration
	private let networkManager: NetworkRequesting

	private enum SpotifyRepositoryError: Error {
		case unauthorized
		case invalidURL
		case invalidURI
	}

	public init(
		configuration: SpotifyAPIConfiguration = DefaultSpotifyAPIConfiguration(),
		networkManager: NetworkRequesting
	) {
		self.configuration = configuration
		self.networkManager = networkManager
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
		} catch let error as NetworkLayer.NetworkError {
			if case .httpError(let code, _) = error, code == 401 {
				self.clearToken()
				let refreshedToken = try await self.getAccessToken(forceRefresh: true)
				return try await self.search(query: query, type: type, token: refreshedToken)
			}
			throw error
		}
	}

	private func getAccessToken(forceRefresh: Bool = false) async throws -> String {
		if !forceRefresh, self.isTokenValid, let token = self.accessToken {
			return token
		}
		if forceRefresh {
			self.clearToken()
		} else if let accessTokenRequest {
			let tokenResponse = try await accessTokenRequest.task.value
			self.storeTokenResponse(tokenResponse)
			return tokenResponse.access_token
		}

		let api = SpotifyAPI.token(config: self.configuration)
		let networkManager = self.networkManager
		let requestID = UUID()
		let requestTask = Task {
			try await networkManager.perform(with: api, as: SpotifyTokenResponse.self)
		}
		self.accessTokenRequest = (requestID, requestTask)

		do {
			let tokenResponse = try await requestTask.value
			self.storeTokenResponse(tokenResponse)
			if self.accessTokenRequest?.id == requestID {
				self.accessTokenRequest = nil
			}
			return tokenResponse.access_token
		} catch {
			if self.accessTokenRequest?.id == requestID {
				self.accessTokenRequest = nil
			}
			throw error
		}
	}

	private func storeTokenResponse(_ tokenResponse: SpotifyTokenResponse) {
		self.accessToken = tokenResponse.access_token
		self.accessTokenExpiry = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
	}

	private func search(query: String, type: String, token: String) async throws -> String {
		let api = SpotifyAPI.search(query: query, type: type, token: token, config: self.configuration)

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

	private func makeURL(from urlString: String) throws -> URL {
		guard let url = URL(string: urlString) else {
			throw SpotifyRepositoryError.invalidURL
		}
		return url
	}

	private var isTokenValid: Bool {
		guard let expiry = self.accessTokenExpiry else { return false }
		return Date().addingTimeInterval(self.configuration.tokenRefreshLeeway) < expiry
	}

	private func clearToken() {
		self.accessToken = nil
		self.accessTokenExpiry = nil
		self.accessTokenRequest?.task.cancel()
		self.accessTokenRequest = nil
	}

	private func fallbackWebURL(query: String) -> URL? {
		let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		return URL(string: "https://open.spotify.com/search/\(encodedQuery)")
	}
}
