//
//  SpotifyArtistImageDTOs.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation

struct SpotifyArtistImageSearchResponseDTO: Decodable {
	let artists: SpotifyArtistImageItemsDTO
}

struct SpotifyArtistImageItemsDTO: Decodable {
	let items: [SpotifyArtistImageItemDTO]
}

struct SpotifyArtistImageItemDTO: Decodable {
	let name: String
	let images: [SpotifyImageDTO]
}

struct SpotifyImageDTO: Decodable {
	let url: String
	let height: Int?
	let width: Int?
}
