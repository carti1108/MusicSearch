import Testing
import Foundation
@testable import MusicSearch

struct LastFMURLTests {

	@Test
	func 유효한https_URL문자열이주어질때_imageURL을호출하면_URL이반환되는지() {
		// given
		let raw = "https://img.last.fm/artist.jpg"

		// when
		let url = LastFMURL.imageURL(from: raw)

		// then
		#expect(url?.absoluteString == "https://img.last.fm/artist.jpg")
	}

	@Test
	func nil이주어질때_imageURL을호출하면_nil이반환되는지() {
		// given
		let raw: String? = nil

		// when
		let url = LastFMURL.imageURL(from: raw)

		// then
		#expect(url == nil)
	}

	@Test
	func 빈문자열이주어질때_imageURL을호출하면_nil이반환되는지() {
		// given
		let raw = ""

		// when
		let url = LastFMURL.imageURL(from: raw)

		// then
		#expect(url == nil)
	}

	@Test
	func 공백문자열이주어질때_imageURL을호출하면_nil이반환되는지() {
		// given
		let raw = "   "

		// when
		let url = LastFMURL.imageURL(from: raw)

		// then
		#expect(url == nil)
	}

	@Test
	func 앞뒤공백이있는URL문자열이주어질때_imageURL을호출하면_정상URL이반환되는지() {
		// given
		let raw = "  https://img.last.fm/artist.jpg  "

		// when
		let url = LastFMURL.imageURL(from: raw)

		// then
		#expect(url?.absoluteString == "https://img.last.fm/artist.jpg")
	}

	@Test
	func http_URL문자열이주어질때_imageURL을호출하면_https로변환되는지() {
		// given
		let raw = "http://img.last.fm/artist.jpg"

		// when
		let url = LastFMURL.imageURL(from: raw)

		// then
		#expect(url?.scheme == "https")
		#expect(url?.absoluteString == "https://img.last.fm/artist.jpg")
	}
}
