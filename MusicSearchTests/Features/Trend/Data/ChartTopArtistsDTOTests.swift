import Testing
import Foundation
@testable import MusicSearch

struct ChartTopArtistsDTOTests {

	@Test
	func mbid가유효한ChartArtistDTO일때_toDomain을호출하면_mbid가id로설정되는지() {
		// given
		let dto = TestDataFactory.makeChartArtistDTO(
			name: "Test Artist",
			listeners: "1000",
			mbid: "valid-artist-mbid"
		)

		// when
		let artist = dto.toDomain()

		// then
		#expect(artist.id == "valid-artist-mbid")
		#expect(artist.name == "Test Artist")
		#expect(artist.listeners == "1000")
	}

	@Test
	func mbid가nil인ChartArtistDTO일때_toDomain을호출하면_UUID가id로설정되는지() {
		// given
		let dto = TestDataFactory.makeChartArtistDTO(name: "Test Artist", mbid: nil)

		// when
		let artist = dto.toDomain()

		// then
		#expect(!artist.id.isEmpty)
		#expect(artist.id != "valid-artist-mbid")
	}

	@Test
	func mbid가빈문자열인ChartArtistDTO일때_toDomain을호출하면_UUID가id로설정되는지() {
		// given
		let dto = TestDataFactory.makeChartArtistDTO(name: "Test Artist", mbid: "")

		// when
		let artist = dto.toDomain()

		// then
		#expect(!artist.id.isEmpty)
	}

	@Test
	func imageURL이있는ChartArtistDTO일때_toDomain을호출하면_imageURL이설정되는지() {
		// given
		let dto = TestDataFactory.makeChartArtistDTO(
			name: "Test Artist",
			imageURL: "https://img.com/artist.jpg"
		)

		// when
		let artist = dto.toDomain()

		// then
		#expect(artist.imageURL?.absoluteString == "https://img.com/artist.jpg")
	}

	@Test
	func imageURL이없는ChartArtistDTO일때_toDomain을호출하면_imageURL이nil인지() {
		// given
		let dto = TestDataFactory.makeChartArtistDTO(name: "Test Artist", imageURL: nil)

		// when
		let artist = dto.toDomain()

		// then
		#expect(artist.imageURL == nil)
	}

	@Test
	func extralarge이미지텍스트가비어있는ChartArtistDTO일때_toDomain을호출하면_다른이미지로대체되는지() {
		// given
		let dto = ChartArtistDTO(
			name: "Test Artist",
			playcount: "100",
			listeners: "500",
			mbid: nil,
			url: "https://last.fm/artist",
			image: [
				LastFMImageDTO(size: "small", text: "https://img.com/small.jpg"),
				LastFMImageDTO(size: "extralarge", text: "")
			]
		)

		// when
		let artist = dto.toDomain()

		// then
		#expect(artist.imageURL?.absoluteString == "https://img.com/small.jpg")
	}

	@Test
	func 모든이미지텍스트가비어있는ChartArtistDTO일때_toDomain을호출하면_imageURL이nil인지() {
		// given
		let dto = ChartArtistDTO(
			name: "Test Artist",
			playcount: "100",
			listeners: "500",
			mbid: nil,
			url: "https://last.fm/artist",
			image: [
				LastFMImageDTO(size: "small", text: ""),
				LastFMImageDTO(size: "extralarge", text: "")
			]
		)

		// when
		let artist = dto.toDomain()

		// then
		#expect(artist.imageURL == nil)
	}

	@Test
	func listeners값이있는ChartArtistDTO일때_toDomain을호출하면_listeners값이정상반환되는지() {
		// given
		let dto = TestDataFactory.makeChartArtistDTO(
			name: "Test Artist",
			listeners: "9999999"
		)

		// when
		let artist = dto.toDomain()

		// then
		#expect(artist.listeners == "9999999")
	}
}
