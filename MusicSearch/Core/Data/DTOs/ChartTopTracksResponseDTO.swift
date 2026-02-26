//
//  ChartTopTracksResponseDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

struct ChartTopTracksResponseDTO: Decodable {
	let tracks: ChartTrackListDTO
}

struct ChartTrackListDTO: Decodable {
	let track: [ChartTrackDTO]
}

struct ChartTrackDTO: Decodable {
	let name: String
	let playcount: String
	let listeners: String
	let mbid: String?
	let url: String?
	let artist: ChartTrackArtistDTO
	let image: [LastFMImageDTO]?

	func toDomain() -> Track {
		let normalizedMBID = self.mbid?.trimmingCharacters(in: .whitespacesAndNewlines)
		let resolvedMBID = (normalizedMBID?.isEmpty == false) ? normalizedMBID : nil
		let imageString = self.image?.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
					   ?? self.image?.first { !$0.text.isEmpty }?.text

		return Track(
			id: resolvedMBID ?? UUID().uuidString,
			mbid: resolvedMBID,
			title: self.name,
			artist: self.artist.name,
			imageURL: LastFMURL.imageURL(from: imageString)
		)
	}
}

struct ChartTrackArtistDTO: Decodable {
	let name: String
	let mbid: String?
	let url: String?
}
