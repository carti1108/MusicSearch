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

	@Test("차트 트랙 유스케이스가 상세 정보를 반영한 결과를 반환하는지 확인")
	mutating func given_차트트랙조회결과가있을때_execute하면_상세정보가반영된트랙을반환하는지() async throws {
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

	@Test("차트 트랙 유스케이스가 일부 상세정보 조회 실패 시 원본 트랙을 유지하는지 확인")
	mutating func given_상세정보조회에일부실패가있을때_execute하면_원본트랙을유지하는지() async throws {
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

	@Test("차트 트랙 유스케이스가 빈 결과를 그대로 반환하는지 확인")
	mutating func given_차트트랙이비어있을때_execute하면_빈배열을반환하는지() async throws {
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

	@Test("차트 트랙 유스케이스가 repository 에러를 전파하는지 확인")
	mutating func given_차트repository에서에러가발생할때_execute하면_에러를전파하는지() async {
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
