//
//  TrackDTO.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
import MSDomain

public struct TrackSearchResponseDTO: Decodable {
	public let results: TrackMatchesContainerDTO
}

public struct TrackMatchesContainerDTO: Decodable {
	public let trackmatches: TrackListDTO
	public let totalResults: String
	public let startIndex: String
	public let itemsPerPage: String

	enum CodingKeys: String, CodingKey {
		case trackmatches
		case totalResults = "opensearch:totalResults"
		case startIndex = "opensearch:startIndex"
		case itemsPerPage = "opensearch:itemsPerPage"
	}
}

public struct TrackListDTO: Decodable {
	public let track: [LastFMTrackSearchDTO]
}

public struct TagTopTracksResponseDTO: Decodable {
	public let tracks: TagTrackListDTO
}

public struct TagTrackListDTO: Decodable {
	public let track: [LastFMTrackTagDTO]
}

public struct TrackSimilarResponseDTO: Decodable {
	public let similartracks: SimilarTrackListDTO
}

public struct SimilarTrackListDTO: Decodable {
	public let track: [LastFMTrackSimilarDTO]
}

public struct LastFMTrackSearchDTO: Decodable {
	public let name: String
	public let artist: String
	public let url: String
	public let mbid: String?
	public let image: [LastFMImageDTO]?

	public func toDomain() -> Track {
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

public struct LastFMTrackTagDTO: Decodable {
	public let name: String
	public let artist: LastFMArtistNameDTO
	public let url: String
	public let mbid: String?
	public let image: [LastFMImageDTO]?

	public func toDomain() -> Track {
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

public struct LastFMTrackSimilarDTO: Decodable {
	public let name: String
	public let artist: LastFMArtistNameDTO
	public let url: String
	public let mbid: String?
	public let image: [LastFMImageDTO]?

	public func toDomain() -> Track {
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

public struct TrackInfoResponseDTO: Decodable {
	public let track: LastFMTrackInfoDTO
}

public struct LastFMTrackInfoDTO: Decodable {
	public let name: String
	public let artist: LastFMArtistNameDTO
	public let album: LastFMAlbumInfoDTO?
}

public struct LastFMAlbumInfoDTO: Decodable {
	public let title: String
	public let image: [LastFMImageDTO]?
}
