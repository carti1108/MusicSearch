//
//  LastFMAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
import NetworkLayer

enum LastFMAPI {
	case searchTracks(keyword: String, limit: Int, page: Int)
	case fetchTopTracks(tag: String)
	case fetchSimilarTracks(track: Track)
	case getTrackInfo(track: Track)
	case getChartTopTracks
	case getChartTopArtists
}

extension LastFMAPI: Requestable {

	private var apiKey: String {
		if let key = Bundle.main.object(forInfoDictionaryKey: "LASTFM_API_KEY") as? String, !key.isEmpty {
			return key
		}

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

	var headers: [HTTPHeader.Field: String]? {
		return nil
	}

	var task: RequestTask {
		var params: [String: Any] = [
			"api_key": apiKey,
			"format": "json"
		]

		switch self {
		case .searchTracks(let keyword, let limit, let page):
			params["method"] = "track.search"
			params["track"] = keyword
			params["limit"] = limit
			params["page"] = page

		case .fetchTopTracks(let tag):
			params["method"] = "tag.gettoptracks"
			params["tag"] = tag

		case .fetchSimilarTracks(let track):
			params["method"] = "track.getsimilar"
			
			if !track.id.isEmpty && track.id.count > 10 {
				params["mbid"] = track.id
			} else {
				params["track"] = track.title
				params["artist"] = track.artist
			}

		case .getTrackInfo(let track):
			params["method"] = "track.getInfo"
			params["track"] = track.title
			params["artist"] = track.artist

		case .getChartTopTracks:
			params["method"] = "chart.gettoptracks"

		case .getChartTopArtists:
			params["method"] = "chart.gettopartists"
		}

		return .requestParameters(parameters: params, encoding: URLQueryEncoder())
	}
}
