import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct LastFMAPITests {

	@Test
	func 모든케이스일때_baseURL에접근하면_audioscrobbler를반환하는지() {
		// given
		let cases: [LastFMAPI] = [
			.searchTracks(keyword: "test", limit: 10, page: 1),
			.fetchTopTracks(tag: "rock"),
			.fetchSimilarTracks(track: TestDataFactory.makeTrack()),
			.getTrackInfo(track: TestDataFactory.makeTrack()),
			.getChartTopTracks,
			.getChartTopArtists
		]

		// then
		for api in cases {
			#expect(api.baseURL.absoluteString == "https://ws.audioscrobbler.com/2.0")
		}
	}

	@Test
	func 모든케이스일때_path에접근하면_빈문자열을반환하는지() {
		// given
		let cases: [LastFMAPI] = [
			.searchTracks(keyword: "test", limit: 10, page: 1),
			.fetchTopTracks(tag: "rock"),
			.getChartTopTracks,
			.getChartTopArtists
		]

		// then
		for api in cases {
			#expect(api.path == "")
		}
	}

	@Test
	func 모든케이스일때_method에접근하면_GET을반환하는지() {
		// given
		let cases: [LastFMAPI] = [
			.searchTracks(keyword: "test", limit: 10, page: 1),
			.fetchTopTracks(tag: "rock"),
			.fetchSimilarTracks(track: TestDataFactory.makeTrack()),
			.getTrackInfo(track: TestDataFactory.makeTrack()),
			.getChartTopTracks,
			.getChartTopArtists
		]

		// then
		for api in cases {
			#expect(api.method == .get)
		}
	}

	@Test
	func 모든케이스일때_headers에접근하면_nil을반환하는지() {
		// given
		let cases: [LastFMAPI] = [
			.searchTracks(keyword: "test", limit: 10, page: 1),
			.getChartTopTracks,
			.getChartTopArtists
		]

		// then
		for api in cases {
			#expect(api.headers == nil)
		}
	}

	@Test
	func 모든케이스일때_task에접근하면_format과api_key파라미터가포함되는지() {
		// given
		let cases: [LastFMAPI] = [
			.searchTracks(keyword: "test", limit: 10, page: 1),
			.fetchTopTracks(tag: "rock"),
			.fetchSimilarTracks(track: TestDataFactory.makeTrack()),
			.getTrackInfo(track: TestDataFactory.makeTrack()),
			.getChartTopTracks,
			.getChartTopArtists
		]

		// then
		for api in cases {
			guard case let .requestParameters(params, _) = api.task else {
				Issue.record("task가 requestParameters가 아님")
				continue
			}
			#expect(params["format"] as? String == "json")
			#expect(params["api_key"] != nil)
		}
	}

	@Test
	func getTrackInfo케이스일때_cachePolicy에접근하면_memory를반환하는지() {
		// given
		let api = LastFMAPI.getTrackInfo(track: TestDataFactory.makeTrack())

		// then
		#expect(api.cachePolicy == .memory)
	}

	@Test
	func searchTracks케이스일때_cachePolicy에접근하면_disk를반환하는지() {
		// given
		let api = LastFMAPI.searchTracks(keyword: "test", limit: 10, page: 1)

		// then
		#expect(api.cachePolicy == .disk)
	}

	@Test
	func fetchTopTracks케이스일때_cachePolicy에접근하면_disk를반환하는지() {
		// given
		let api = LastFMAPI.fetchTopTracks(tag: "rock")

		// then
		#expect(api.cachePolicy == .disk)
	}

	@Test
	func fetchSimilarTracks케이스일때_cachePolicy에접근하면_disk를반환하는지() {
		// given
		let api = LastFMAPI.fetchSimilarTracks(track: TestDataFactory.makeTrack())

		// then
		#expect(api.cachePolicy == .disk)
	}

	@Test
	func getChartTopTracks케이스일때_cachePolicy에접근하면_disk를반환하는지() {
		// given
		let api = LastFMAPI.getChartTopTracks

		// then
		#expect(api.cachePolicy == .disk)
	}

	@Test
	func getChartTopArtists케이스일때_cachePolicy에접근하면_disk를반환하는지() {
		// given
		let api = LastFMAPI.getChartTopArtists

		// then
		#expect(api.cachePolicy == .disk)
	}

	@Test
	func searchTracks케이스일때_task에접근하면_keyword와limit과page가포함되는지() {
		// given
		let api = LastFMAPI.searchTracks(keyword: "beatles", limit: 20, page: 2)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["method"] as? String == "track.search")
		#expect(params["track"] as? String == "beatles")
		#expect(params["limit"] as? Int == 20)
		#expect(params["page"] as? Int == 2)
	}

	@Test
	func fetchTopTracks케이스일때_task에접근하면_tag가포함되는지() {
		// given
		let api = LastFMAPI.fetchTopTracks(tag: "jazz")

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["method"] as? String == "tag.gettoptracks")
		#expect(params["tag"] as? String == "jazz")
	}

	@Test
	func 유효한mbid가있는트랙으로fetchSimilarTracks케이스를생성할때_task에접근하면_mbid가포함되는지() {
		// given
		let track = TestDataFactory.makeTrack(mbid: "valid-mbid-123", title: "Creep", artist: "Radiohead")
		let api = LastFMAPI.fetchSimilarTracks(track: track)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["method"] as? String == "track.getsimilar")
		#expect(params["mbid"] as? String == "valid-mbid-123")
		#expect(params["track"] == nil)
		#expect(params["artist"] == nil)
	}

	@Test
	func mbid가nil인트랙으로fetchSimilarTracks케이스를생성할때_task에접근하면_track과artist가포함되는지() {
		// given
		let track = TestDataFactory.makeTrack(mbid: nil, title: "Creep", artist: "Radiohead")
		let api = LastFMAPI.fetchSimilarTracks(track: track)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["method"] as? String == "track.getsimilar")
		#expect(params["track"] as? String == "Creep")
		#expect(params["artist"] as? String == "Radiohead")
		#expect(params["mbid"] == nil)
	}

	@Test
	func mbid가공백문자열인트랙으로fetchSimilarTracks케이스를생성할때_task에접근하면_track과artist가포함되는지() {
		// given
		let track = TestDataFactory.makeTrack(mbid: "   ", title: "Creep", artist: "Radiohead")
		let api = LastFMAPI.fetchSimilarTracks(track: track)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["mbid"] == nil)
		#expect(params["track"] as? String == "Creep")
		#expect(params["artist"] as? String == "Radiohead")
	}

	@Test
	func mbid가빈문자열인트랙으로fetchSimilarTracks케이스를생성할때_task에접근하면_track과artist가포함되는지() {
		// given
		let track = TestDataFactory.makeTrack(mbid: "", title: "Karma Police", artist: "Radiohead")
		let api = LastFMAPI.fetchSimilarTracks(track: track)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["mbid"] == nil)
		#expect(params["track"] as? String == "Karma Police")
		#expect(params["artist"] as? String == "Radiohead")
	}

	@Test
	func getTrackInfo케이스일때_task에접근하면_track과artist가포함되는지() {
		// given
		let track = TestDataFactory.makeTrack(title: "Bohemian Rhapsody", artist: "Queen")
		let api = LastFMAPI.getTrackInfo(track: track)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["method"] as? String == "track.getInfo")
		#expect(params["track"] as? String == "Bohemian Rhapsody")
		#expect(params["artist"] as? String == "Queen")
	}

	@Test
	func getChartTopTracks케이스일때_task에접근하면_올바른method가포함되는지() {
		// given
		let api = LastFMAPI.getChartTopTracks

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["method"] as? String == "chart.gettoptracks")
	}

	@Test
	func getChartTopArtists케이스일때_task에접근하면_올바른method가포함되는지() {
		// given
		let api = LastFMAPI.getChartTopArtists

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["method"] as? String == "chart.gettopartists")
	}
}
