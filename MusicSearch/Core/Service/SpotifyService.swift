//
//  SpotifyService.swift
//  MusicSearch
//
//  Created by Kiseok on 2026/02/10.
//

import UIKit

protocol SpotifyServiceProtocol: AnyObject {
	func openSpotify(for track: Track)
	func openSpotify(for artist: String)
}

final class SpotifyService: SpotifyServiceProtocol {
	
	private let clientId: String
	private let clientSecret: String
	private var accessToken: String?
	
	init(clientId: String, clientSecret: String) {
		self.clientId = clientId
		self.clientSecret = clientSecret
	}
	
	func openSpotify(for track: Track) {
		let query = "\(track.title) \(track.artist)"
		self.searchAndOpen(query: query, type: "track")
	}
	
	func openSpotify(for artist: String) {
		self.searchAndOpen(query: artist, type: "artist")
	}
	
	private func searchAndOpen(query: String, type: String) {
		Task {
			do {
				let start = CFAbsoluteTimeGetCurrent()
				
				let token = try await self.getAccessToken()
				let uri = try await self.search(query: query, type: type, token: token)
				
				let duration = CFAbsoluteTimeGetCurrent() - start
				print("Spotify Search Duration: \(duration)s")
				
				await MainActor.run {
					self.openDeepLink(uri: uri)
				}
			} catch {
				print("Spotify Service Error: \(error)")
				// Fallback to simple search deep link if API fails
				await MainActor.run {
					self.fallbackToSearch(query: query, type: type)
				}
			}
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
			return item.uri
		} else {
			let result = try JSONDecoder().decode(SpotifyArtistSearchResponse.self, from: data)
			guard let item = result.artists.items.first else { throw URLError(.resourceUnavailable) }
			return item.uri
		}
	}
	
	private func openDeepLink(uri: String) {
		let appURL = URL(string: uri)!
		if UIApplication.shared.canOpenURL(appURL) {
			UIApplication.shared.open(appURL)
		} else {
			// Extract ID from URI (spotify:track:ID)
			let components = uri.components(separatedBy: ":")
			guard components.count == 3 else { return }
			let type = components[1]
			let id = components[2]
			let webURL = URL(string: "https://open.spotify.com/\(type)/\(id)")!
			UIApplication.shared.open(webURL)
		}
	}
	
	private func fallbackToSearch(query: String, type: String) {
		let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		let appURL = URL(string: "spotify://search/\(encodedQuery)")!
		let webURL = URL(string: "https://open.spotify.com/search/\(encodedQuery)")!
		
		if UIApplication.shared.canOpenURL(appURL) {
			UIApplication.shared.open(appURL)
		} else {
			UIApplication.shared.open(webURL)
		}
	}
}

// MARK: - DTOs

struct SpotifyTokenResponse: Decodable {
	let access_token: String
	let token_type: String
	let expires_in: Int
}

struct SpotifyTrackSearchResponse: Decodable {
	let tracks: SpotifyItems<SpotifyItem>
}

struct SpotifyArtistSearchResponse: Decodable {
	let artists: SpotifyItems<SpotifyItem>
}

struct SpotifyItems<T: Decodable>: Decodable {
	let items: [T]
}

struct SpotifyItem: Decodable {
	let uri: String
}
