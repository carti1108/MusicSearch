//
//  SpotifyAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 2026/02/10.
//

import Foundation
import NetworkLayer

public protocol SpotifyAPIConfiguration: Sendable {
	var accountsBaseURL: String { get }
	var apiBaseURL: String { get }
	var clientId: String { get }
	var clientSecret: String { get }
	var tokenRefreshLeeway: TimeInterval { get }
	var redirectURI: String { get }
}

public struct DefaultSpotifyAPIConfiguration: SpotifyAPIConfiguration {
	public var accountsBaseURL: String { "https://accounts.spotify.com" }
	public var apiBaseURL: String { "https://api.spotify.com" }
	public var clientId: String {
		Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String ?? ""
	}
	public var clientSecret: String {
		Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_SECRET") as? String ?? ""
	}
	public var tokenRefreshLeeway: TimeInterval { 60 }
	public var redirectURI: String { "musicsearch://spotify-login-callback" }

	public init() {}
}

public enum SpotifyAPI {
	case token(config: SpotifyAPIConfiguration)
	case exchangeToken(code: String, config: SpotifyAPIConfiguration)
	case search(query: String, type: String, token: String, config: SpotifyAPIConfiguration)
	case artistSearch(query: String, token: String, limit: Int, config: SpotifyAPIConfiguration)
	case me(token: String, config: SpotifyAPIConfiguration)
}

extension SpotifyAPI: Requestable {
	public 
	var cachePolicy: CachePolicy {
		switch self {
		case .token, .exchangeToken:
			return .memory
		case .search, .artistSearch, .me:
			return .memory
		}
	}

	public var baseURL: URL {
		switch self {
		case .token(let config), .exchangeToken(_, let config):
			return URL(string: config.accountsBaseURL)!
		case .search(_, _, _, let config), .artistSearch(_, _, _, let config), .me(_, let config):
			return URL(string: config.apiBaseURL)!
		}
	}

	public var path: String {
		switch self {
		case .token, .exchangeToken:
			return "/api/token"
		case .search, .artistSearch:
			return "/v1/search"
		case .me:
			return "/v1/me"
		}
	}

	public var method: HTTPMethod {
		switch self {
		case .token, .exchangeToken:
			return .post
		case .search, .artistSearch, .me:
			return .get
		}
	}

	public var headers: [HTTPHeader.Field: String]? {
		switch self {
		case .token(let config), .exchangeToken(_, let config):
			let credentialData = "\(config.clientId):\(config.clientSecret)".data(using: .utf8)!
			let base64Credentials = credentialData.base64EncodedString()
			return [
				.authorization: "Basic \(base64Credentials)",
				.contentType: "application/x-www-form-urlencoded"
			]
		case .search(_, _, let token, _), .artistSearch(_, let token, _, _), .me(let token, _):
			return [
				.authorization: "Bearer \(token)"
			]
		}
	}

	public var task: RequestTask {
		switch self {
		case .token:
			return .requestParameters(
				parameters: ["grant_type": "client_credentials"],
				encoding: URLFormEncoder()
			)
		case .exchangeToken(let code, let config):
			return .requestParameters(
				parameters: [
					"grant_type": "authorization_code",
					"code": code,
					"redirect_uri": config.redirectURI
				],
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
		case .me:
			return .requestPlain
		}
	}
}
