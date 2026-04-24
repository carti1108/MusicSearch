import Foundation
import NetworkLayer
import Testing
@testable import MusicSearch

struct LastFMAPITests {
	@Test
	func searchTracks요청을생성하면_메서드와페이지파라미터가설정되는지() {
		let request = LastFMAPI.searchTracks(keyword: "Muse", limit: 20, page: 3)

		#expect(request.method == .get)
		#expect(request.baseURL.absoluteString == "https://ws.audioscrobbler.com/2.0")
		#expect(request.cachePolicy == .disk)

		guard case let .requestParameters(parameters, encoding) = request.task else {
			Issue.record("쿼리 파라미터 요청이어야 합니다.")
			return
		}

		#expect(parameters["method"] as? String == "track.search")
		#expect(parameters["track"] as? String == "Muse")
		#expect(parameters["limit"] as? Int == 20)
		#expect(parameters["page"] as? Int == 3)
		#expect(String(describing: encoding) == String(describing: URLQueryEncoder()))
	}

	@Test
	func fetchSimilarTracks에서mbid가있으면_track과artist대신mbid를사용하는지() {
		let track = Track(id: "1", mbid: "mbid-123", title: "Hysteria", artist: "Muse", imageURL: nil)
		let request = LastFMAPI.fetchSimilarTracks(track: track)

		guard case let .requestParameters(parameters, _) = request.task else {
			Issue.record("쿼리 파라미터 요청이어야 합니다.")
			return
		}

		#expect(parameters["method"] as? String == "track.getsimilar")
		#expect(parameters["mbid"] as? String == "mbid-123")
		#expect(parameters["track"] == nil)
		#expect(parameters["artist"] == nil)
	}

	@Test
	func fetchSimilarTracks에서mbid가없으면_track과artist를사용하는지() {
		let track = Track(id: "1", mbid: nil, title: "Hysteria", artist: "Muse", imageURL: nil)
		let request = LastFMAPI.fetchSimilarTracks(track: track)

		guard case let .requestParameters(parameters, _) = request.task else {
			Issue.record("쿼리 파라미터 요청이어야 합니다.")
			return
		}

		#expect(parameters["method"] as? String == "track.getsimilar")
		#expect(parameters["track"] as? String == "Hysteria")
		#expect(parameters["artist"] as? String == "Muse")
		#expect(parameters["mbid"] == nil)
	}
}
