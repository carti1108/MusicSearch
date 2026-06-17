//
//  LastFMCommonDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

public struct LastFMImageDTO: Decodable {
	public let size: String
	public let text: String

	enum CodingKeys: String, CodingKey {
		case size
		case text = "#text"
	}
}

public struct LastFMArtistNameDTO: Decodable {
	public let name: String
	public let mbid: String?
	public let url: String
}
