import Testing
import Foundation
@testable import MusicSearch

struct AlbumTests {

	@Test
	func imageURL없이Album을생성할때_init을호출하면_기본값이올바르게설정되는지() {
		// given / when
		let album = Album(title: "Abbey Road", artist: "The Beatles", imageURL: nil)

		// then
		#expect(!album.id.isEmpty)
		#expect(album.title == "Abbey Road")
		#expect(album.artist == "The Beatles")
		#expect(album.imageURL == nil)
		#expect(album.releaseDate == nil)
		#expect(album.playCount == nil)
	}

	@Test
	func 모든파라미터를지정하여Album을생성할때_init을호출하면_해당값들이설정되는지() {
		// given
		let imageURL = URL(string: "https://example.com/cover.jpg")
		let releaseDate = Date(timeIntervalSince1970: 0)

		// when
		let album = Album(
			id: "custom-id",
			title: "OK Computer",
			artist: "Radiohead",
			imageURL: imageURL,
			releaseDate: releaseDate,
			playCount: 1000
		)

		// then
		#expect(album.id == "custom-id")
		#expect(album.title == "OK Computer")
		#expect(album.artist == "Radiohead")
		#expect(album.imageURL == imageURL)
		#expect(album.releaseDate == releaseDate)
		#expect(album.playCount == 1000)
	}
}
