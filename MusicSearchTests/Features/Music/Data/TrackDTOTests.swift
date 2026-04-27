import Testing
import Foundation
@testable import MusicSearch

struct TrackDTOTests {

	@Test
	func mbid가유효한LastFMTrackSearchDTO일때_toDomain을호출하면_mbid가id로설정되는지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: "valid-mbid",
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == "valid-mbid")
		#expect(track.id == "valid-mbid")
		#expect(track.title == "Test Track")
		#expect(track.artist == "Test Artist")
	}

	@Test
	func mbid가nil인LastFMTrackSearchDTO일때_toDomain을호출하면_mbid가nil이고UUID가id로설정되는지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: nil,
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
		#expect(!track.id.isEmpty)
	}

	@Test
	func mbid가빈문자열인LastFMTrackSearchDTO일때_toDomain을호출하면_mbid가nil이되는지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: "",
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
	}

	@Test
	func mbid가공백문자열인LastFMTrackSearchDTO일때_toDomain을호출하면_mbid가nil이되는지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: "   ",
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
	}

	@Test
	func extralarge이미지가있는LastFMTrackSearchDTO일때_toDomain을호출하면_해당이미지URL이설정되는지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: nil,
			image: [
				LastFMImageDTO(size: "small", text: "https://img.com/small.jpg"),
				LastFMImageDTO(size: "extralarge", text: "https://img.com/large.jpg")
			]
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL?.absoluteString == "https://img.com/large.jpg")
	}

	@Test
	func extralarge이미지텍스트가비어있는LastFMTrackSearchDTO일때_toDomain을호출하면_첫번째유효이미지가사용되는지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: nil,
			image: [
				LastFMImageDTO(size: "small", text: "https://img.com/small.jpg"),
				LastFMImageDTO(size: "extralarge", text: "")
			]
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL?.absoluteString == "https://img.com/small.jpg")
	}

	@Test
	func 이미지배열이없는LastFMTrackSearchDTO일때_toDomain을호출하면_imageURL이nil인지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: nil,
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL == nil)
	}

	@Test
	func 모든이미지텍스트가비어있는LastFMTrackSearchDTO일때_toDomain을호출하면_imageURL이nil인지() {
		// given
		let dto = LastFMTrackSearchDTO(
			name: "Test Track",
			artist: "Test Artist",
			url: "https://last.fm/track",
			mbid: nil,
			image: [
				LastFMImageDTO(size: "small", text: ""),
				LastFMImageDTO(size: "extralarge", text: "")
			]
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL == nil)
	}

	@Test
	func mbid가유효한LastFMTrackTagDTO일때_toDomain을호출하면_mbid가설정되는지() {
		// given
		let dto = LastFMTrackTagDTO(
			name: "Tag Track",
			artist: LastFMArtistNameDTO(name: "Tag Artist", mbid: nil, url: ""),
			url: "https://last.fm/track",
			mbid: "tag-mbid",
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == "tag-mbid")
		#expect(track.artist == "Tag Artist")
	}

	@Test
	func mbid가빈문자열인LastFMTrackTagDTO일때_toDomain을호출하면_mbid가nil이되는지() {
		// given
		let dto = LastFMTrackTagDTO(
			name: "Tag Track",
			artist: LastFMArtistNameDTO(name: "Tag Artist", mbid: nil, url: ""),
			url: "https://last.fm/track",
			mbid: "",
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
	}

	@Test
	func extralarge이미지가없는LastFMTrackTagDTO일때_toDomain을호출하면_첫번째유효이미지가사용되는지() {
		// given
		let dto = LastFMTrackTagDTO(
			name: "Tag Track",
			artist: LastFMArtistNameDTO(name: "Tag Artist", mbid: nil, url: ""),
			url: "https://last.fm/track",
			mbid: nil,
			image: [
				LastFMImageDTO(size: "small", text: "https://img.com/small.jpg"),
				LastFMImageDTO(size: "extralarge", text: "")
			]
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL?.absoluteString == "https://img.com/small.jpg")
	}

	@Test
	func mbid가유효한LastFMTrackSimilarDTO일때_toDomain을호출하면_mbid가설정되는지() {
		// given
		let dto = LastFMTrackSimilarDTO(
			name: "Similar Track",
			artist: LastFMArtistNameDTO(name: "Similar Artist", mbid: nil, url: ""),
			url: "https://last.fm/track",
			mbid: "similar-mbid",
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == "similar-mbid")
		#expect(track.artist == "Similar Artist")
	}

	@Test
	func mbid가공백인LastFMTrackSimilarDTO일때_toDomain을호출하면_mbid가nil이되는지() {
		// given
		let dto = LastFMTrackSimilarDTO(
			name: "Similar Track",
			artist: LastFMArtistNameDTO(name: "Similar Artist", mbid: nil, url: ""),
			url: "https://last.fm/track",
			mbid: "   ",
			image: nil
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
	}

	@Test
	func 이미지가있는LastFMTrackSimilarDTO일때_toDomain을호출하면_imageURL이설정되는지() {
		// given
		let dto = LastFMTrackSimilarDTO(
			name: "Similar Track",
			artist: LastFMArtistNameDTO(name: "Similar Artist", mbid: nil, url: ""),
			url: "https://last.fm/track",
			mbid: nil,
			image: [
				LastFMImageDTO(size: "extralarge", text: "https://img.com/similar.jpg")
			]
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL?.absoluteString == "https://img.com/similar.jpg")
	}

	@Test
	func extralarge이미지텍스트가비어있는LastFMTrackSimilarDTO일때_toDomain을호출하면_첫번째유효이미지가사용되는지() {
		// given
		let dto = LastFMTrackSimilarDTO(
			name: "Similar Track",
			artist: LastFMArtistNameDTO(name: "Similar Artist", mbid: nil, url: ""),
			url: "https://last.fm/track",
			mbid: nil,
			image: [
				LastFMImageDTO(size: "medium", text: "https://img.com/medium.jpg"),
				LastFMImageDTO(size: "extralarge", text: "")
			]
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL?.absoluteString == "https://img.com/medium.jpg")
	}
}
