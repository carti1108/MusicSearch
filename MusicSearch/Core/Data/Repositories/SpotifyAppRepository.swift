//
//  SpotifyAppRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation

final class SpotifyAppRepository: MusicAppRepository {
	
	private let clientId: String
	private let clientSecret: String
	private var accessToken: String?
	
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
			let token = try await self.getAccessToken()
			let urlString = try await self.search(query: query, type: type, token: token)
			return URL(string: urlString)
		} catch {
			print("SpotifyService Error: \(error)")
			
			return self.fallbackWebURL(query: query)
		}
	}
	
	private func getAccessToken() async throws -> String {
		if let token = self.accessToken {
			return token
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
		return tokenResponse.access_token
	}
	
	private func search(query: String, type: String, token: String) async throws -> String {
		let api = SpotifyAPI.search(query: query, type: type, token: token)
		var components = URLComponents(url: api.url, resolvingAgainstBaseURL: true)!
		components.queryItems = api.queryItems
		
		var request = URLRequest(url: components.url!)
		request.httpMethod = api.method
		request.allHTTPHeaderFields = api.headers
		
		let (data, response) = try await URLSession.shared.data(for: request)
		
		guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}
		
		if type == "track" {
			let result = try JSONDecoder().decode(SpotifyTrackSearchResponse.self, from: data)
			guard let item = result.tracks.items.first else { throw URLError(.resourceUnavailable) }

			return item.external_urls?.spotify ?? self.convertToWebURL(uri: item.uri)
		} else {
			let result = try JSONDecoder().decode(SpotifyArtistSearchResponse.self, from: data)
			guard let item = result.artists.items.first else { throw URLError(.resourceUnavailable) }
			return item.external_urls?.spotify ?? self.convertToWebURL(uri: item.uri)
		}
	}
	
	private func convertToWebURL(uri: String) -> String {

		let components = uri.components(separatedBy: ":")
		guard components.count == 3 else { return "" }
		let type = components[1]
		let id = components[2]
		return "https://open.spotify.com/\(type)/\(id)"
	}
	
	private func fallbackWebURL(query: String) -> URL? {
		let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		return URL(string: "https://open.spotify.com/search/\(encodedQuery)")
	}
}
