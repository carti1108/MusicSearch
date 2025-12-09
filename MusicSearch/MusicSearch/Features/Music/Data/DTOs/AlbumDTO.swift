//
//  AlbumDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

struct ArtistTopAlbumsResponseDTO: Decodable {
	let topalbums: AlbumListDTO
}

struct AlbumListDTO: Decodable {
	let album: [LastFMAlbumDTO]
}

struct AlbumInfoResponseDTO: Decodable {
	let album: LastFMAlbumDTO
}

struct LastFMAlbumDTO: Decodable {
	let name: String
	let artist: LastFMArtistSimpleDTO
	let mbid: String?
	let url: String
	let image: [LastFMImageDTO]?
	let playcount: Int?
	let wiki: LastFMWikiDTO?

	func toDomain() -> Album {
		let imageString = self.image?.first { $0.size == "extralarge" }?.text
					   ?? self.image?.last?.text
		var date: Date? = nil
		if let dateString = self.wiki?.published {
			date = DateFormatter.lastFMDateFormatter.date(from: dateString)
		}

		return Album(
			id: (self.mbid?.isEmpty == false) ? self.mbid! : UUID().uuidString,
			title: self.name,
			artist: self.artist.name,
			imageURL: URL(string: imageString ?? ""),
			releaseDate: date,
			playCount: self.playcount
		)
	}
}

struct LastFMArtistSimpleDTO: Decodable {
	let name: String
	let mbid: String?
	let url: String
}

struct LastFMWikiDTO: Decodable {
	let published: String?
	let summary: String?
}

extension DateFormatter {
	static let lastFMDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = "d MMM yyyy, HH:mm" 

		return formatter
	}()
}
