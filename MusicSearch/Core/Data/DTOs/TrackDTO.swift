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
	let totalResults: String
	let startIndex: String
	let itemsPerPage: String

	enum CodingKeys: String, CodingKey {
		case trackmatches
		case totalResults = "opensearch:totalResults"
		case startIndex = "opensearch:startIndex"
		case itemsPerPage = "opensearch:itemsPerPage"
	}
}

struct TrackListDTO: Decodable {
	let track: [LastFMTrackSearchDTO]
}

struct TagTopTracksResponseDTO: Decodable {
	let tracks: TagTrackListDTO
}

struct TagTrackListDTO: Decodable {
	let track: [LastFMTrackTagDTO]
}

struct TrackSimilarResponseDTO: Decodable {
	let similartracks: SimilarTrackListDTO
}

struct SimilarTrackListDTO: Decodable {
	let track: [LastFMTrackSimilarDTO]
}

struct LastFMTrackSearchDTO: Decodable {
	let name: String
	let artist: String
	let url: String
	let mbid: String?
	let image: [LastFMImageDTO]?

	func toDomain() -> Track {
		let normalizedMBID = self.mbid?.trimmingCharacters(in: .whitespacesAndNewlines)
		let resolvedMBID = (normalizedMBID?.isEmpty == false) ? normalizedMBID : nil
		let imageString = self.image?.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
					   ?? self.image?.first { !$0.text.isEmpty }?.text

		let imageURL = LastFMURL.imageURL(from: imageString)

		return Track(
			id: resolvedMBID ?? UUID().uuidString,
			mbid: resolvedMBID,
			title: self.name,
			artist: self.artist,
			imageURL: imageURL
		)
	}
}

struct LastFMTrackTagDTO: Decodable {
	let name: String
	let artist: LastFMArtistNameDTO
	let url: String
	let mbid: String?
	let image: [LastFMImageDTO]?

	func toDomain() -> Track {
		let normalizedMBID = self.mbid?.trimmingCharacters(in: .whitespacesAndNewlines)
		let resolvedMBID = (normalizedMBID?.isEmpty == false) ? normalizedMBID : nil
		let imageString = self.image?.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
					   ?? self.image?.first { !$0.text.isEmpty }?.text

		let imageURL = LastFMURL.imageURL(from: imageString)

		return Track(
			id: resolvedMBID ?? UUID().uuidString,
			mbid: resolvedMBID,
			title: self.name,
			artist: self.artist.name,
			imageURL: imageURL
		)
	}
}

struct LastFMTrackSimilarDTO: Decodable {
	let name: String
	let artist: LastFMArtistNameDTO
	let url: String
	let mbid: String?
	let image: [LastFMImageDTO]?

	func toDomain() -> Track {
		let normalizedMBID = self.mbid?.trimmingCharacters(in: .whitespacesAndNewlines)
		let resolvedMBID = (normalizedMBID?.isEmpty == false) ? normalizedMBID : nil
		let imageString = self.image?.first { $0.size == "extralarge" && !$0.text.isEmpty }?.text
					   ?? self.image?.first { !$0.text.isEmpty }?.text

		let imageURL = LastFMURL.imageURL(from: imageString)

		return Track(
			id: resolvedMBID ?? UUID().uuidString,
			mbid: resolvedMBID,
			title: self.name,
			artist: self.artist.name,
			imageURL: imageURL
		)
	}
}

struct TrackInfoResponseDTO: Decodable {
	let track: LastFMTrackInfoDTO
}

struct LastFMTrackInfoDTO: Decodable {
	let name: String
	let artist: LastFMArtistNameDTO
	let album: LastFMAlbumInfoDTO?
}

struct LastFMAlbumInfoDTO: Decodable {
	let title: String
	let image: [LastFMImageDTO]?
}
