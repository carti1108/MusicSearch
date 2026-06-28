//
//  ChartTopArtistsDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import MSData

import Foundation
import MSDomain

struct ChartTopArtistsResponseDTO: Decodable {
	let artists: ChartArtistListDTO
}

struct ChartArtistListDTO: Decodable {
	let artist: [ChartArtistDTO]
}

struct ChartArtistDTO: Decodable {
	let name: String
	let playcount: String
	let listeners: String
	let mbid: String?
	let url: String?
	let image: [LastFMImageDTO]?

	func toDomain() -> Artist {
		let imageString = self.image?.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
					   ?? self.image?.first { !$0.text.isEmpty }?.text

		return Artist(
			id: (self.mbid?.isEmpty == false) ? self.mbid! : UUID().uuidString,
			name: self.name,
			imageURL: LastFMURL.imageURL(from: imageString),
			listeners: self.listeners
		)
	}
}
