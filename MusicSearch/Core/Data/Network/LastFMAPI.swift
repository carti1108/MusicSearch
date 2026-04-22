//
//  LastFMAPI.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation
import NetworkLayer

protocol LastFMAPIConfiguration {
	var baseURL: String { get }
	var apiKey: String { get }
}

struct DefaultLastFMAPIConfiguration: LastFMAPIConfiguration {
	var baseURL: String { "https://ws.audioscrobbler.com/2.0" }
	var apiKey: String {
		Bundle.main.object(forInfoDictionaryKey: "LASTFM_API_KEY") as? String ?? ""
	}
}

enum LastFMAPI {
	case searchTracks(keyword: String, limit: Int, page: Int, config: LastFMAPIConfiguration)
	case fetchTopTracks(tag: String, config: LastFMAPIConfiguration)
	case fetchSimilarTracks(track: Track, config: LastFMAPIConfiguration)
	case getTrackInfo(track: Track, config: LastFMAPIConfiguration)
	case getChartTopTracks(config: LastFMAPIConfiguration)
	case getChartTopArtists(config: LastFMAPIConfiguration)
}

extension LastFMAPI: Requestable {

	private var config: LastFMAPIConfiguration {
		switch self {
		case .searchTracks(_, _, _, let config),
			 .fetchTopTracks(_, let config),
			 .fetchSimilarTracks(_, let config),
			 .getTrackInfo(_, let config),
			 .getChartTopTracks(let config),
			 .getChartTopArtists(let config):
			return config
		}
	}

	var baseURL: URL {
		return URL(string: self.config.baseURL)!
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

	var cachePolicy: CachePolicy {
		switch self {
		case .getTrackInfo(_, _):
			return .memory
		case .searchTracks(_, _, _, _),
			 .fetchTopTracks(_, _),
			 .fetchSimilarTracks(_, _),
			 .getChartTopTracks(_),
			 .getChartTopArtists(_):
			return .disk
		}
	}

	var task: RequestTask {
		var params: [String: Any] = [
			"api_key": self.config.apiKey,
			"format": "json"
		]

		switch self {
		case .searchTracks(let keyword, let limit, let page, _):
			params["method"] = "track.search"
			params["track"] = keyword
			params["limit"] = limit
			params["page"] = page

		case .fetchTopTracks(let tag, _):
			params["method"] = "tag.gettoptracks"
			params["tag"] = tag

		case .fetchSimilarTracks(let track, _):
			params["method"] = "track.getsimilar"

			if let mbid = track.mbid?.trimmingCharacters(in: .whitespacesAndNewlines), !mbid.isEmpty {
				params["mbid"] = mbid
			} else {
				params["track"] = track.title
				params["artist"] = track.artist
			}

		case .getTrackInfo(let track, _):
			params["method"] = "track.getInfo"
			params["track"] = track.title
			params["artist"] = track.artist

		case .getChartTopTracks(_):
			params["method"] = "chart.gettoptracks"

		case .getChartTopArtists(_):
			params["method"] = "chart.gettopartists"
		}

		return .requestParameters(parameters: params, encoding: URLQueryEncoder())
	}
}
