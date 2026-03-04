//
//  SpotifyAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 2026/02/10.
//

import Foundation
import NetworkLayer

enum SpotifyAPI {
	case token(clientId: String, clientSecret: String)
	case search(query: String, type: String, token: String)
}

extension SpotifyAPI: Requestable {
	var cachePolicy: CachePolicy {
		switch self {
		case .token:
			return .memory
		case .search:
			return .memory
		}
	}

	var baseURL: URL {
		switch self {
		case .token:
			return URL(string: "https://accounts.spotify.com")!
		case .search:
			return URL(string: "https://api.spotify.com")!
		}
	}

	var path: String {
		switch self {
		case .token:
			return "/api/token"
		case .search:
			return "/v1/search"
		}
	}

	var method: HTTPMethod {
		switch self {
		case .token:
			return .post
		case .search:
			return .get
		}
	}

	var headers: [HTTPHeader.Field: String]? {
		switch self {
		case .token(let clientId, let clientSecret):
			let credentialData = "\(clientId):\(clientSecret)".data(using: .utf8)!
			let base64Credentials = credentialData.base64EncodedString()
			return [
				.authorization: "Basic \(base64Credentials)",
				.contentType: "application/x-www-form-urlencoded"
			]
		case .search(_, _, let token):
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
		case .search(let query, let type, _):
			return .requestParameters(
				parameters: [
					"q": query,
					"type": type,
					"limit": "1"
				],
				encoding: URLQueryEncoder()
			)
		}
	}
}
