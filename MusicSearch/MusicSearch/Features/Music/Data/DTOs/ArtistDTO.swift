//
//  ArtistDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

struct ArtistSearchResponseDTO: Decodable {
	let results: ArtistMatchesContainerDTO
}

struct ArtistMatchesContainerDTO: Decodable {
	let artistmatches: ArtistListDTO
}

struct ArtistListDTO: Decodable {
	let artist: [LastFMArtistDTO]
}

struct ArtistInfoResponseDTO: Decodable {
	let artist: LastFMArtistDTO
}

struct LastFMArtistDTO: Decodable {
	let name: String
	let mbid: String?
	let url: String
	let image: [LastFMImageDTO]?
	let listeners: String?
	let tags: LastFMTagsContainerDTO?
	let bio: LastFMBioDTO?

	func toDomain() -> Artist {
		let targetImage = image?.first { $0.size == "mega" }
					   ?? image?.first { $0.size == "extralarge" }
					   ?? image?.last
		let tagList = tags?.tag.map { $0.name } ?? []

		return Artist(
			id: (mbid?.isEmpty == false) ? mbid! : UUID().uuidString,
			name: name,
			imageURL: URL(string: targetImage?.text ?? ""),
			listeners: listeners,
			tags: tagList,
			bio: bio?.summary
		)
	}
}

struct LastFMTagsContainerDTO: Decodable {
	let tag: [LastFMTagDTO]
}

struct LastFMTagDTO: Decodable {
	let name: String
	let url: String
}

struct LastFMBioDTO: Decodable {
	let summary: String
	let content: String
}
