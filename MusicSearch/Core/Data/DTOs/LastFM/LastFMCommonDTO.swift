//
//  LastFMCommonDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

struct LastFMImageDTO: Decodable {
	let size: String
	let text: String

	enum CodingKeys: String, CodingKey {
		case size
		case text = "#text"
	}
}

struct LastFMArtistNameDTO: Decodable {
	let name: String
	let mbid: String?
	let url: String
}
