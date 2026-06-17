//
//  SpotifyArtistImageDTOs.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation

public struct SpotifyArtistImageSearchResponseDTO: Decodable {
	public let artists: SpotifyArtistImageItemsDTO
}

public struct SpotifyArtistImageItemsDTO: Decodable {
	public let items: [SpotifyArtistImageItemDTO]
}

public struct SpotifyArtistImageItemDTO: Decodable {
	public let name: String
	public let images: [SpotifyImageDTO]
}

public struct SpotifyImageDTO: Decodable {
	public let url: String
	public let height: Int?
	public let width: Int?
}
