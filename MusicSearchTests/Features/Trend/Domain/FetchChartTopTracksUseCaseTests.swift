import Testing
import Foundation
@testable import MusicSearch

struct FetchChartTopTracksUseCaseTests {
	var mockChartRepository: MockChartRepository
	var mockTrackRepository: MockTrackRepository

	init() {
		self.mockChartRepository = MockChartRepository()
		self.mockTrackRepository = MockTrackRepository()
	}

	@Test
	mutating func 차트트랙조회결과가있을때_execute하면_상세정보가반영된트랙을반환하는지() async throws {
		// given
		let rawTracks = [
			TestDataFactory.makeTrack(id: "1", title: "Track 1", artist: "Artist 1"),
			TestDataFactory.makeTrack(id: "2", title: "Track 2", artist: "Artist 2")
		]
		self.mockChartRepository.fetchTopTracksResult = .success(rawTracks)
		self.mockTrackRepository.fetchTrackInfoHandler = { track in
			TestDataFactory.makeTrack(
				id: track.id,
				title: track.title,
				artist: track.artist,
				imageURL: "https://image.test/\(track.id).jpg"
			)
		}
		let useCase = FetchChartTopTracksUseCaseImpl(
			chartRepository: self.mockChartRepository,
			trackRepository: self.mockTrackRepository
		)

		// when
		let tracks = try await useCase.execute()

		// then
		#expect(tracks.count == 2)
		#expect(tracks.allSatisfy { $0.imageURL != nil })
		#expect(self.mockChartRepository.fetchTopTracksCallCount == 1)
		#expect(self.mockTrackRepository.fetchTrackInfoCallCount == 2)
	}

	@Test
	mutating func 상세정보조회에일부실패가있을때_execute하면_원본트랙을유지하는지() async throws {
		// given
		enum TestError: Error {
			case failed
		}

		let firstTrack = TestDataFactory.makeTrack(id: "1", title: "Track 1", artist: "Artist 1")
		let secondTrack = TestDataFactory.makeTrack(id: "2", title: "Track 2", artist: "Artist 2")
		self.mockChartRepository.fetchTopTracksResult = .success([firstTrack, secondTrack])
		self.mockTrackRepository.fetchTrackInfoHandler = { track in
			if track.id == secondTrack.id {
				throw TestError.failed
			}

			return TestDataFactory.makeTrack(
				id: track.id,
				title: track.title,
				artist: track.artist,
				imageURL: "https://image.test/\(track.id).jpg"
			)
		}
		let useCase = FetchChartTopTracksUseCaseImpl(
			chartRepository: self.mockChartRepository,
			trackRepository: self.mockTrackRepository
		)

		// when
		let tracks = try await useCase.execute()

		// then
		#expect(tracks.count == 2)
		#expect(tracks[0].imageURL?.absoluteString == "https://image.test/1.jpg")
		#expect(tracks[1] == secondTrack)
	}

	@Test
	mutating func 차트트랙이비어있을때_execute하면_빈배열을반환하는지() async throws {
		// given
		self.mockChartRepository.fetchTopTracksResult = .success([])
		let useCase = FetchChartTopTracksUseCaseImpl(
			chartRepository: self.mockChartRepository,
			trackRepository: self.mockTrackRepository
		)

		// when
		let tracks = try await useCase.execute()

		// then
		#expect(tracks.isEmpty)
		#expect(self.mockTrackRepository.fetchTrackInfoCallCount == 0)
	}

	@Test
	mutating func 차트repository에서에러가발생할때_execute하면_에러를전파하는지() async {
		// given
		enum TestError: Error {
			case failed
		}

		self.mockChartRepository.fetchTopTracksResult = .failure(TestError.failed)
		let useCase = FetchChartTopTracksUseCaseImpl(
			chartRepository: self.mockChartRepository,
			trackRepository: self.mockTrackRepository
		)

		// when
		await #expect(throws: TestError.self) {
			try await useCase.execute()
		}

		// then
		#expect(self.mockTrackRepository.fetchTrackInfoCallCount == 0)
	}
}
