import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct MockSpotifyAPIConfiguration: SpotifyAPIConfiguration {
	var accountsBaseURL: String = "https://accounts.spotify.com"
	var apiBaseURL: String = "https://api.spotify.com"
	var clientId: String = "test_client_id"
	var clientSecret: String = "test_client_secret"
	var tokenRefreshLeeway: TimeInterval = 60
}

struct SpotifyAPITests {

	let config = MockSpotifyAPIConfiguration()

	@Test
	func token케이스일때_baseURL에접근하면_accountsBaseURL을반환하는지() {
		// given
		let api = SpotifyAPI.token(config: config)

		// then
		#expect(api.baseURL.absoluteString == "https://accounts.spotify.com")
	}

	@Test
	func token케이스일때_path에접근하면_api_token을반환하는지() {
		// given
		let api = SpotifyAPI.token(config: config)

		// then
		#expect(api.path == "/api/token")
	}

	@Test
	func token케이스일때_method에접근하면_POST를반환하는지() {
		// given
		let api = SpotifyAPI.token(config: config)

		// then
		#expect(api.method == .post)
	}

	@Test
	func token케이스일때_headers에접근하면_Basic인증정보가포함되는지() {
		// given
		let api = SpotifyAPI.token(config: config)
		let credentialData = "test_client_id:test_client_secret".data(using: .utf8)!
		let expectedBase64 = credentialData.base64EncodedString()

		// then
		#expect(api.headers?[.authorization] == "Basic \(expectedBase64)")
		#expect(api.headers?[.contentType] == "application/x-www-form-urlencoded")
	}

	@Test
	func token케이스일때_task에접근하면_grant_type파라미터가포함되는지() {
		// given
		let api = SpotifyAPI.token(config: config)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["grant_type"] as? String == "client_credentials")
	}

	@Test
	func token케이스일때_cachePolicy에접근하면_memory를반환하는지() {
		// given
		let api = SpotifyAPI.token(config: config)

		// then
		#expect(api.cachePolicy == .memory)
	}

	@Test
	func search케이스일때_baseURL에접근하면_apiBaseURL을반환하는지() {
		// given
		let api = SpotifyAPI.search(query: "test", type: "track", token: "tok", config: config)

		// then
		#expect(api.baseURL.absoluteString == "https://api.spotify.com")
	}

	@Test
	func search케이스일때_path에접근하면_v1_search를반환하는지() {
		// given
		let api = SpotifyAPI.search(query: "test", type: "track", token: "tok", config: config)

		// then
		#expect(api.path == "/v1/search")
	}

	@Test
	func search케이스일때_method에접근하면_GET을반환하는지() {
		// given
		let api = SpotifyAPI.search(query: "test", type: "track", token: "tok", config: config)

		// then
		#expect(api.method == .get)
	}

	@Test
	func search케이스일때_headers에접근하면_Bearer토큰이포함되는지() {
		// given
		let api = SpotifyAPI.search(query: "test", type: "track", token: "my_token", config: config)

		// then
		#expect(api.headers?[.authorization] == "Bearer my_token")
	}

	@Test
	func search케이스일때_task에접근하면_쿼리파라미터가포함되는지() {
		// given
		let api = SpotifyAPI.search(query: "beatles", type: "track", token: "tok", config: config)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["q"] as? String == "beatles")
		#expect(params["type"] as? String == "track")
		#expect(params["limit"] as? String == "1")
	}

	@Test
	func search케이스일때_cachePolicy에접근하면_memory를반환하는지() {
		// given
		let api = SpotifyAPI.search(query: "test", type: "track", token: "tok", config: config)

		// then
		#expect(api.cachePolicy == .memory)
	}

	@Test
	func artistSearch케이스일때_baseURL에접근하면_apiBaseURL을반환하는지() {
		// given
		let api = SpotifyAPI.artistSearch(query: "artist", token: "tok", limit: 5, config: config)

		// then
		#expect(api.baseURL.absoluteString == "https://api.spotify.com")
	}

	@Test
	func artistSearch케이스일때_path에접근하면_v1_search를반환하는지() {
		// given
		let api = SpotifyAPI.artistSearch(query: "artist", token: "tok", limit: 5, config: config)

		// then
		#expect(api.path == "/v1/search")
	}

	@Test
	func artistSearch케이스일때_method에접근하면_GET을반환하는지() {
		// given
		let api = SpotifyAPI.artistSearch(query: "artist", token: "tok", limit: 5, config: config)

		// then
		#expect(api.method == .get)
	}

	@Test
	func artistSearch케이스일때_headers에접근하면_Bearer토큰이포함되는지() {
		// given
		let api = SpotifyAPI.artistSearch(query: "artist", token: "art_token", limit: 5, config: config)

		// then
		#expect(api.headers?[.authorization] == "Bearer art_token")
	}

	@Test
	func artistSearch케이스일때_task에접근하면_artist타입과limit파라미터가포함되는지() {
		// given
		let api = SpotifyAPI.artistSearch(query: "radiohead", token: "tok", limit: 3, config: config)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["q"] as? String == "radiohead")
		#expect(params["type"] as? String == "artist")
		#expect(params["limit"] as? String == "3")
	}

	@Test
	func artistSearch케이스에limit이설정될때_task에접근하면_해당limit값이반영되는지() {
		// given
		let api = SpotifyAPI.artistSearch(query: "test", token: "tok", limit: 10, config: config)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["limit"] as? String == "10")
	}

	@Test
	func artistSearch케이스일때_cachePolicy에접근하면_memory를반환하는지() {
		// given
		let api = SpotifyAPI.artistSearch(query: "artist", token: "tok", limit: 1, config: config)

		// then
		#expect(api.cachePolicy == .memory)
	}
}
