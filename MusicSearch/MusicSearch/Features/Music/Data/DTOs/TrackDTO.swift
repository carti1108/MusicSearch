//
//  TrackDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

struct TrackSearchResponseDTO: Decodable {
	let results: TrackMatchesContainerDTO
}

struct TrackMatchesContainerDTO: Decodable {
	let trackmatches: TrackListDTO
}

struct TrackListDTO: Decodable {
	let track: [LastFMTrackDTO]
}

struct TagTopTracksResponseDTO: Decodable {
	let tracks: TagTrackListDTO
}

struct TagTrackListDTO: Decodable {
	let track: [LastFMTrackDTO]
}
struct LastFMTrackDTO: Decodable {
	let name: String
	let artist: String
	let url: String
	let mbid: String?
	let image: [LastFMImageDTO]?

	func toDomain() -> Track {
		let imageString = self.image?.first { $0.size == "extralarge" }?.text
					   ?? self.image?.last?.text

		return Track(
			id: (self.mbid?.isEmpty == false) ? self.mbid! : UUID().uuidString,
			title: self.name,
			artist: self.artist,
			imageURL: URL(string: imageString ?? "")
		)
	}
}

struct TrackSimilarResponseDTO: Decodable {
	let similartracks: SimilarTrackListDTO
}

struct SimilarTrackListDTO: Decodable {
	let track: [LastFMTrackDTO]
}

struct LastFMImageDTO: Decodable {
	let size: String
	let text: String

	enum CodingKeys: String, CodingKey {
		case size
		case text = "#text"
	}
}
