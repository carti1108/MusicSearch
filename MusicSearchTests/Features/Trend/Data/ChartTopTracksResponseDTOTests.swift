import Testing
import Foundation
@testable import MusicSearch

struct ChartTopTracksResponseDTOTests {

	@Test
	func mbid가유효한ChartTrackDTO일때_toDomain을호출하면_mbid가id로설정되는지() {
		// given
		let dto = TestDataFactory.makeChartTrackDTO(
			name: "Test Track",
			artist: "Test Artist",
			mbid: "valid-track-mbid"
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.id == "valid-track-mbid")
		#expect(track.mbid == "valid-track-mbid")
		#expect(track.title == "Test Track")
		#expect(track.artist == "Test Artist")
	}

	@Test
	func mbid가nil인ChartTrackDTO일때_toDomain을호출하면_UUID가id로설정되는지() {
		// given
		let dto = TestDataFactory.makeChartTrackDTO(name: "Test Track", mbid: nil)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
		#expect(!track.id.isEmpty)
	}

	@Test
	func mbid가빈문자열인ChartTrackDTO일때_toDomain을호출하면_mbid가nil이고UUID가id로설정되는지() {
		// given
		let dto = TestDataFactory.makeChartTrackDTO(name: "Test Track", mbid: "")

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
		#expect(!track.id.isEmpty)
	}

	@Test
	func mbid가공백문자열인ChartTrackDTO일때_toDomain을호출하면_mbid가nil이되는지() {
		// given
		let dto = TestDataFactory.makeChartTrackDTO(name: "Test Track", mbid: "   ")

		// when
		let track = dto.toDomain()

		// then
		#expect(track.mbid == nil)
	}

	@Test
	func imageURL이있는ChartTrackDTO일때_toDomain을호출하면_imageURL이설정되는지() {
		// given
		let dto = TestDataFactory.makeChartTrackDTO(
			name: "Test Track",
			imageURL: "https://img.com/track.jpg"
		)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL?.absoluteString == "https://img.com/track.jpg")
	}

	@Test
	func imageURL이없는ChartTrackDTO일때_toDomain을호출하면_imageURL이nil인지() {
		// given
		let dto = TestDataFactory.makeChartTrackDTO(name: "Test Track", imageURL: nil)

		// when
		let track = dto.toDomain()

		// then
		#expect(track.imageURL == nil)
	}

	@Test
	func extralarge이미지텍스트가비어있는ChartTrackDTO일때_toDomain을호출하면_다른이미지로대체되는지() {
		// given
		let dto = ChartTrackDTO(
			name: "Test Track",
			playcount: "100",
			listeners: "50",
			mbid: nil,
			url: nil,
			artist: ChartTrackArtistDTO(name: "Test Artist", mbid: nil, url: nil),
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

	@Test
	func 모든이미지텍스트가비어있는ChartTrackDTO일때_toDomain을호출하면_imageURL이nil인지() {
		// given
		let dto = ChartTrackDTO(
			name: "Test Track",
			playcount: "100",
			listeners: "50",
			mbid: nil,
			url: nil,
			artist: ChartTrackArtistDTO(name: "Test Artist", mbid: nil, url: nil),
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
}
