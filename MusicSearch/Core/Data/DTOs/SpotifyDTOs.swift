//
//  SpotifyDTOs.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation

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
	let external_urls: SpotifyExternalURLs?
}

struct SpotifyExternalURLs: Decodable {
	let spotify: String
}
