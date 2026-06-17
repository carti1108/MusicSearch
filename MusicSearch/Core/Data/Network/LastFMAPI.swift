//
//  LastFMAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
import NetworkLayer
import MSDomain

public enum LastFMAPI {
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

	public var baseURL: URL {
		return URL(string: "https://ws.audioscrobbler.com/2.0")!
	}

	public var path: String {
		return ""
	}

	public var method: HTTPMethod {
		return .get
	}

	public var headers: [HTTPHeader.Field: String]? {
		return nil
	}

	public var cachePolicy: CachePolicy {
		switch self {
		case .getTrackInfo:
			return .memory
		case .searchTracks, .fetchTopTracks, .fetchSimilarTracks, .getChartTopTracks, .getChartTopArtists:
			return .disk
		}
	}

	public var task: RequestTask {
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

			if let mbid = track.mbid?.trimmingCharacters(in: .whitespacesAndNewlines), !mbid.isEmpty {
				params["mbid"] = mbid
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
