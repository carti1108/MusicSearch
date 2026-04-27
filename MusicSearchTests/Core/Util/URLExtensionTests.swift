import Testing
import Foundation
@testable import MusicSearch

struct URLExtensionTests {

	@Test
	func http_URL일때_forcedHTTPS를호출하면_https로변환되는지() {
		// given
		let url = URL(string: "http://example.com")!

		// when
		let result = url.forcedHTTPS

		// then
		#expect(result.scheme == "https")
		#expect(result.absoluteString == "https://example.com")
	}

	@Test
	func https_URL일때_forcedHTTPS를호출하면_그대로반환되는지() {
		// given
		let url = URL(string: "https://example.com")!

		// when
		let result = url.forcedHTTPS

		// then
		#expect(result.absoluteString == "https://example.com")
	}

	@Test
	func 경로와쿼리가있는http_URL일때_forcedHTTPS를호출하면_scheme만https로변환되는지() {
		// given
		let url = URL(string: "http://example.com/path?key=value")!

		// when
		let result = url.forcedHTTPS

		// then
		#expect(result.scheme == "https")
		#expect(result.host == "example.com")
		#expect(result.path == "/path")
		#expect(result.query == "key=value")
	}

	@Test
	func ftp_URL일때_forcedHTTPS를호출하면_그대로반환되는지() {
		// given
		let url = URL(string: "ftp://example.com/file")!

		// when
		let result = url.forcedHTTPS

		// then
		#expect(result.scheme == "ftp")
	}

	@Test
	func http_URL일때_forcedHTTPS를호출하면_원본과host가동일한지() {
		// given
		let url = URL(string: "http://img.last.fm/photo.jpg")!

		// when
		let result = url.forcedHTTPS

		// then
		#expect(result.host == url.host)
		#expect(result.path == url.path)
	}
}
