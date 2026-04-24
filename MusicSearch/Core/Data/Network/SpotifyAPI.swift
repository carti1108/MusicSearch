//
//  SpotifyAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 2026/02/10.
//

import Foundation
import NetworkLayer

protocol SpotifyAPIConfiguration: Sendable {
	var accountsBaseURL: String { get }
	var apiBaseURL: String { get }
	var clientId: String { get }
	var clientSecret: String { get }
	var tokenRefreshLeeway: TimeInterval { get }
}

struct DefaultSpotifyAPIConfiguration: SpotifyAPIConfiguration {
	var accountsBaseURL: String { "https://accounts.spotify.com" }
	var apiBaseURL: String { "https://api.spotify.com" }
	var clientId: String {
		Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String ?? ""
	}
	var clientSecret: String {
		Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_SECRET") as? String ?? ""
	}
	var tokenRefreshLeeway: TimeInterval { 60 }
}

enum SpotifyAPI {
	case token(config: SpotifyAPIConfiguration)
	case search(query: String, type: String, token: String, config: SpotifyAPIConfiguration)
	case artistSearch(query: String, token: String, limit: Int, config: SpotifyAPIConfiguration)
}

extension SpotifyAPI: Requestable {
	var cachePolicy: CachePolicy {
		switch self {
		case .token:
			return .memory
		case .search, .artistSearch:
			return .memory
		}
	}

	var baseURL: URL {
		switch self {
		case .token(let config):
			return URL(string: config.accountsBaseURL)!
		case .search(_, _, _, let config), .artistSearch(_, _, _, let config):
			return URL(string: config.apiBaseURL)!
		}
	}

	var path: String {
		switch self {
		case .token:
			return "/api/token"
		case .search, .artistSearch:
			return "/v1/search"
		}
	}

	var method: HTTPMethod {
		switch self {
		case .token:
			return .post
		case .search, .artistSearch:
			return .get
		}
	}

	var headers: [HTTPHeader.Field: String]? {
		switch self {
		case .token(let config):
			let credentialData = "\(config.clientId):\(config.clientSecret)".data(using: .utf8)!
			let base64Credentials = credentialData.base64EncodedString()
			return [
				.authorization: "Basic \(base64Credentials)",
				.contentType: "application/x-www-form-urlencoded"
			]
		case .search(_, _, let token, _), .artistSearch(_, let token, _, _):
			return [
				.authorization: "Bearer \(token)"
			]
		}
	}

	var task: RequestTask {
		switch self {
		case .token:
			return .requestParameters(
				parameters: ["grant_type": "client_credentials"],
				encoding: URLFormEncoder()
			)
		case .search(let query, let type, _, _):
			return .requestParameters(
				parameters: [
					"q": query,
					"type": type,
					"limit": "1"
				],
				encoding: URLQueryEncoder()
			)
		case .artistSearch(let query, _, let limit, _):
			return .requestParameters(
				parameters: [
					"q": query,
					"type": "artist",
					"limit": "\(limit)"
				],
				encoding: URLQueryEncoder()
			)
		}
	}
}
