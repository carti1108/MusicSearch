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
	public let tracks: SpotifyItems<SpotifyItem>
}

public struct SpotifyArtistSearchResponse: Decodable {
	public let artists: SpotifyItems<SpotifyItem>
}

public struct SpotifyItems<T: Decodable>: Decodable {
	public let items: [T]
}

public struct SpotifyItem: Decodable {
	public let uri: String
	public let external_urls: SpotifyExternalURLs?
}

public struct SpotifyExternalURLs: Decodable {
	public let spotify: String
}
