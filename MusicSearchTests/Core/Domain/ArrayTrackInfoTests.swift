import Testing
import Foundation
@testable import MusicSearch

struct ArrayTrackInfoTests {

	@Test
	func 트랙배열이비어있을때_enrichingTrackInfo를호출하면_빈배열을반환하는지() async {
		// given
		let tracks: [Track] = []

		// when
		let result = await tracks.enrichingTrackInfo { track in
			return track
		}

		// then
		#expect(result.isEmpty)
	}

	@Test
	func 트랙수가maxConcurrentRequests이하일때_enrichingTrackInfo를호출하면_모든트랙이처리되는지() async {
		// given
		let tracks = [
			TestDataFactory.makeTrack(title: "Track 1"),
			TestDataFactory.makeTrack(title: "Track 2"),
			TestDataFactory.makeTrack(title: "Track 3")
		]

		// when
		let result = await tracks.enrichingTrackInfo(maxConcurrentRequests: 8) { track in
			return track
		}

		// then
		#expect(result.count == 3)
	}

	@Test
	func 트랙수가maxConcurrentRequests보다많을때_enrichingTrackInfo를호출하면_모든트랙이처리되는지() async {
		// given
		let tracks = [
			TestDataFactory.makeTrack(title: "Track 1"),
			TestDataFactory.makeTrack(title: "Track 2"),
			TestDataFactory.makeTrack(title: "Track 3"),
			TestDataFactory.makeTrack(title: "Track 4"),
			TestDataFactory.makeTrack(title: "Track 5")
		]

		// when
		let result = await tracks.enrichingTrackInfo(maxConcurrentRequests: 2) { track in
			return track
		}

		// then
		#expect(result.count == 5)
	}

	@Test
	func fetch클로저가에러를던질때_enrichingTrackInfo를호출하면_실패한트랙은원본을유지하는지() async {
		// given
		let original = TestDataFactory.makeTrack(title: "Original")
		let tracks = [original]

		// when
		let result = await tracks.enrichingTrackInfo(maxConcurrentRequests: 1) { _ in
			throw NSError(domain: "test", code: -1)
		}

		// then
		#expect(result.count == 1)
		#expect(result[0].title == "Original")
	}

	@Test
	func maxConcurrentRequests가1일때_enrichingTrackInfo를호출하면_순차적으로모든트랙을처리하는지() async {
		// given
		let tracks = [
			TestDataFactory.makeTrack(title: "A"),
			TestDataFactory.makeTrack(title: "B"),
			TestDataFactory.makeTrack(title: "C")
		]
		var processedTitles: [String] = []

		// when
		let result = await tracks.enrichingTrackInfo(maxConcurrentRequests: 1) { track in
			processedTitles.append(track.title)
			return track
		}

		// then
		#expect(result.count == 3)
		#expect(processedTitles.count == 3)
	}
}
