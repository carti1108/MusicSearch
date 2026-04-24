import Foundation
import NetworkLayer
import Testing
@testable import MusicSearch

private struct StubSpotifyAPIConfiguration: SpotifyAPIConfiguration {
	let accountsBaseURL: String
	let apiBaseURL: String
	let clientId: String
	let clientSecret: String
	let tokenRefreshLeeway: TimeInterval
}

struct SpotifyAPITests {
	private let configuration = StubSpotifyAPIConfiguration(
		accountsBaseURL: "https://accounts.test",
		apiBaseURL: "https://api.test",
		clientId: "client-id",
		clientSecret: "client-secret",
		tokenRefreshLeeway: 30
	)

	@Test
	func token요청을생성하면_post헤더와폼파라미터가설정되는지() {
		let request = SpotifyAPI.token(config: self.configuration)

		#expect(request.baseURL.absoluteString == "https://accounts.test")
		#expect(request.path == "/api/token")
		#expect(request.method == .post)
		#expect(request.headers?[.contentType] == "application/x-www-form-urlencoded")

		guard case let .requestParameters(parameters, encoding) = request.task else {
			Issue.record("폼 파라미터 요청이어야 합니다.")
			return
		}

		#expect(parameters["grant_type"] as? String == "client_credentials")
		#expect(String(describing: encoding) == String(describing: URLFormEncoder()))
	}

	@Test
	func search요청을생성하면_bearer토큰과쿼리파라미터가설정되는지() {
		let request = SpotifyAPI.search(
			query: "Muse",
			type: "track",
			token: "bearer-token",
			config: self.configuration
		)

		#expect(request.baseURL.absoluteString == "https://api.test")
		#expect(request.path == "/v1/search")
		#expect(request.method == .get)
		#expect(request.headers?[.authorization] == "Bearer bearer-token")

		guard case let .requestParameters(parameters, _) = request.task else {
			Issue.record("쿼리 파라미터 요청이어야 합니다.")
			return
		}

		#expect(parameters["q"] as? String == "Muse")
		#expect(parameters["type"] as? String == "track")
		#expect(parameters["limit"] as? String == "1")
	}

	@Test
	func artistSearch요청을생성하면_limit이문자열로반영되는지() {
		let request = SpotifyAPI.artistSearch(
			query: "Muse",
			token: "bearer-token",
			limit: 5,
			config: self.configuration
		)

		guard case let .requestParameters(parameters, _) = request.task else {
			Issue.record("쿼리 파라미터 요청이어야 합니다.")
			return
		}

		#expect(parameters["q"] as? String == "Muse")
		#expect(parameters["type"] as? String == "artist")
		#expect(parameters["limit"] as? String == "5")
	}
}
