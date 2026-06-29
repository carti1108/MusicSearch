//
//  SpotifyDTOs.swift
//  MusicSearch
//
//  Created by Kiseok on 2/10/26.
//

import Foundation

public struct SpotifyTokenResponse: Decodable {
	public let access_token: String
	public let token_type: String
	public let expires_in: Int
	public let refresh_token: String?
}

public struct SpotifyUserProfileResponse: Decodable {
    public let display_name: String?
    public let id: String
    public let images: [SpotifyImage]?
}

public struct SpotifyImage: Decodable {
    public let url: String
    public let height: Int?
    public let width: Int?
}

public struct SpotifyTrackSearchResponse: Decodable {
	public let tracks: SpotifyItems<SpotifyTrackDTO>
}

public struct SpotifyArtistSearchResponse: Decodable {
	public let artists: SpotifyItems<SpotifyArtistDTO>
}

public struct SpotifyItems<T: Decodable>: Decodable {
	public let items: [T]
	public let total: Int?
}

public struct SpotifyArtistDTO: Decodable {
	public let id: String?
	public let name: String
	public let uri: String?
	public let external_urls: SpotifyExternalURLs?
}

public struct SpotifyAlbumDTO: Decodable {
	public let id: String
	public let name: String
	public let album_type: String?
	public let release_date: String?
	public let images: [SpotifyImage]?
}

public struct SpotifyTrackDTO: Decodable {
	public let id: String
	public let name: String
	public let uri: String
	public let artists: [SpotifyArtistDTO]
	public let album: SpotifyAlbumDTO?
	public let external_urls: SpotifyExternalURLs?
}

import MSDomain

extension SpotifyTrackDTO {
	public func toDomain() -> Track {
		let artistName = self.artists.map { $0.name }.joined(separator: ", ")
		let imageString = self.album?.images?.first?.url
		let imageURL = imageString.flatMap { URL(string: $0) }
		let thumbnailString = self.album?.images?.last?.url
		let thumbnailURL = thumbnailString.flatMap { URL(string: $0) }
		
		var parsedReleaseDate: Date? = nil
		if let releaseDateString = self.album?.release_date {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd"
			parsedReleaseDate = formatter.date(from: releaseDateString)
			if parsedReleaseDate == nil {
				formatter.dateFormat = "yyyy"
				parsedReleaseDate = formatter.date(from: releaseDateString)
			}
		}

		return Track(
			id: self.id,
			mbid: nil,
			title: self.name,
			artist: artistName,
			imageURL: imageURL,
			thumbnailURL: thumbnailURL,
			albumTitle: self.album?.name,
			albumType: self.album?.album_type,
			releaseDate: parsedReleaseDate
		)
	}
}

public struct SpotifyExternalURLs: Decodable {
	public let spotify: String
}

public struct SpotifyPlaylistResponse: Decodable {
    public let id: String
    public let uri: String
}

public struct SpotifySnapshotResponse: Decodable {
    public let snapshot_id: String
}
