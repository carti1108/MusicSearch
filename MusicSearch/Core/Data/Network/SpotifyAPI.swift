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
	case search(query: String, type: String, limit: Int, offset: Int, token: String, config: SpotifyAPIConfiguration)
	case artistSearch(query: String, token: String, limit: Int, config: SpotifyAPIConfiguration)
	case me(token: String, config: SpotifyAPIConfiguration)
	case createPlaylist(userId: String, name: String, token: String, config: SpotifyAPIConfiguration)
	case addItemsToPlaylist(playlistId: String, uris: [String], token: String, config: SpotifyAPIConfiguration)
}

extension SpotifyAPI: Requestable {
	public 
	var cachePolicy: CachePolicy {
		switch self {
		case .token, .exchangeToken:
			return .memory
		case .search, .artistSearch, .me, .createPlaylist, .addItemsToPlaylist:
			return .memory
		}
	}

	public var baseURL: URL {
		switch self {
		case .token(let config), .exchangeToken(_, let config):
			return URL(string: config.accountsBaseURL)!
		case .search(_, _, _, _, _, let config), .artistSearch(_, _, _, let config), .me(_, let config), .createPlaylist(_, _, _, let config), .addItemsToPlaylist(_, _, _, let config):
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
		case .createPlaylist(let userId, _, _, _):
			return "/v1/users/\(userId)/playlists"
		case .addItemsToPlaylist(let playlistId, _, _, _):
			return "/v1/playlists/\(playlistId)/tracks"
		}
	}

	public var method: HTTPMethod {
		switch self {
		case .token, .exchangeToken:
			return .post
		case .search, .artistSearch, .me:
			return .get
		case .createPlaylist, .addItemsToPlaylist:
			return .post
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
		case .search(_, _, _, _, let token, _), .artistSearch(_, let token, _, _), .me(let token, _), .createPlaylist(_, _, let token, _), .addItemsToPlaylist(_, _, let token, _):
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
		case .search(let query, let type, let limit, let offset, _, _):
			return .requestParameters(
				parameters: [
					"q": query,
					"type": type,
					"limit": "\(limit)",
					"offset": "\(offset)"
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
		case .createPlaylist(_, let name, _, _):
			struct CreatePlaylistRequest: Encodable {
				let name: String
				let `public`: Bool
				let description: String
			}
			return .requestJSONEncodable(CreatePlaylistRequest(name: name, public: false, description: "MusicSearch Archive Playlist"))
		case .addItemsToPlaylist(_, let uris, _, _):
			struct AddItemsRequest: Encodable {
				let uris: [String]
			}
			return .requestJSONEncodable(AddItemsRequest(uris: uris))
		}
	}
}
