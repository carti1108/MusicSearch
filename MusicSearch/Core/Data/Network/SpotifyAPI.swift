//
//  SpotifyAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 2026/02/10.
//

import Foundation

enum SpotifyAPI {
	case token(clientId: String, clientSecret: String)
	case search(query: String, type: String, token: String)
	case artistSearch(query: String, token: String, limit: Int)

	var url: URL {
		switch self {
		case .token:
			return URL(string: "https://accounts.spotify.com/api/token")!
		case .search, .artistSearch:
			return URL(string: "https://api.spotify.com/v1/search")!
		}
	}

	var method: String {
		switch self {
		case .token:
			return "POST"
		case .search, .artistSearch:
			return "GET"
		}
	}

	var headers: [String: String] {
		switch self {
		case .token(let clientId, let clientSecret):
			let credentialData = "\(clientId):\(clientSecret)".data(using: .utf8)!
			let base64Credentials = credentialData.base64EncodedString()
			return [
				"Authorization": "Basic \(base64Credentials)",
				"Content-Type": "application/x-www-form-urlencoded"
			]
		case .search(_, _, let token), .artistSearch(_, let token, _):
			return [
				"Authorization": "Bearer \(token)"
			]
		}
	}

	var body: Data? {
		switch self {
		case .token:
			return "grant_type=client_credentials".data(using: .utf8)
		case .search, .artistSearch:
			return nil
		}
	}

	var queryItems: [URLQueryItem]? {
		switch self {
		case .token:
			return nil
		case .search(let query, let type, _):
			return [
				URLQueryItem(name: "q", value: query),
				URLQueryItem(name: "type", value: type),
				URLQueryItem(name: "limit", value: "1")
			]
		case .artistSearch(let query, _, let limit):
			return [
				URLQueryItem(name: "q", value: query),
				URLQueryItem(name: "type", value: "artist"),
				URLQueryItem(name: "limit", value: "\(limit)")
			]
		}
	}
}
