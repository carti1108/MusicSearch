//
//  LastFMAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
import NetworkLayer

enum LastFMAPI {
	case searchTracks(keyword: String)
	case fetchTopTracks(tag: String)
	case fetchSimilarTracks(track: Track)
	case searchArtists(keyword: String)
	case fetchArtistAlbums(artist: Artist)
}

extension LastFMAPI: Requestable {

	private var apiKey: String {
		if let key = Bundle.main.object(forInfoDictionaryKey: "LASTFM_API_KEY") as? String, !key.isEmpty {
			return key
		}

		print("🚨 [LastFMAPI] API Key가 설정되지 않았습니다!")
		return ""
	}

	var baseURL: URL {
		return URL(string: "https://ws.audioscrobbler.com/2.0")!
	}

	var path: String {
		return ""
	}

	var method: HTTPMethod {
		return .get
	}

	var queryParameters: [String: Any]? {
		var params: [String: Any] = [
			"api_key": apiKey,
			"format": "json"
		]

		switch self {
		case .searchTracks(let keyword):
			params["method"] = "track.search"
			params["track"] = keyword

		case .fetchTopTracks(let tag):
			params["method"] = "tag.gettoptracks"
			params["tag"] = tag

		case .fetchSimilarTracks(let track):
			params["method"] = "track.getsimilar"
			params["track"] = track.title
			params["artist"] = track.artist

		case .searchArtists(let keyword):
			params["method"] = "artist.search"
			params["artist"] = keyword

		case .fetchArtistAlbums(let artist):
			params["method"] = "artist.gettopalbums"
			params["artist"] = artist.name
		}

		return params
	}
}
