import Testing
import Foundation
@testable import MusicSearch

struct TrackEnrichmentFallbackTests {
	@Test("검색 유스케이스가 상세정보 일부 실패 시 원본 트랙을 유지하는지 확인")
	func given_상세정보조회가일부실패할때_searchTrackUseCase를실행하면_실패한트랙은원본을유지하는지() async throws {
		// given
		enum TestError: Error {
			case failed
		}

		let repository = MockTrackRepository()
		let firstTrack = TestDataFactory.makeTrack(id: "1", title: "Track 1", artist: "Artist 1")
		let secondTrack = TestDataFactory.makeTrack(id: "2", title: "Track 2", artist: "Artist 2")
		repository.searchTracksResult = .success(([firstTrack, secondTrack], 2))
		repository.fetchTrackInfoHandler = { track in
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
		let useCase = SearchTrackUseCaseImpl(trackRepository: repository)

		// when
		let result = try await useCase.execute(query: "keyword", limit: 20, page: 1)

		// then
		#expect(result.totalResults == 2)
		#expect(result.tracks[0].imageURL?.absoluteString == "https://image.test/1.jpg")
		#expect(result.tracks[1] == secondTrack)
	}

	@Test("태그 유스케이스가 상세정보 일부 실패 시 원본 트랙을 유지하는지 확인")
	func given_상세정보조회가일부실패할때_fetchTracksByTagUseCase를실행하면_실패한트랙은원본을유지하는지() async throws {
		// given
		enum TestError: Error {
			case failed
		}

		let repository = MockTrackRepository()
		let firstTrack = TestDataFactory.makeTrack(id: "1", title: "Track 1", artist: "Artist 1")
		let secondTrack = TestDataFactory.makeTrack(id: "2", title: "Track 2", artist: "Artist 2")
		repository.fetchTopTracksResult = .success([firstTrack, secondTrack])
		repository.fetchTrackInfoHandler = { track in
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
		let useCase = FetchTracksByTagUseCaseImpl(trackRepository: repository)

		// when
		let tracks = try await useCase.execute(tag: "pop")

		// then
		#expect(tracks[0].imageURL?.absoluteString == "https://image.test/1.jpg")
		#expect(tracks[1] == secondTrack)
	}

	@Test("유사곡 유스케이스가 상세정보 일부 실패 시 원본 트랙을 유지하는지 확인")
	func given_상세정보조회가일부실패할때_fetchSimilarTracksUseCase를실행하면_실패한트랙은원본을유지하는지() async throws {
		// given
		enum TestError: Error {
			case failed
		}

		let repository = MockTrackRepository()
		let targetTrack = TestDataFactory.makeTrack(id: "seed", title: "Seed", artist: "Artist")
		let firstTrack = TestDataFactory.makeTrack(id: "1", title: "Track 1", artist: "Artist 1")
		let secondTrack = TestDataFactory.makeTrack(id: "2", title: "Track 2", artist: "Artist 2")
		repository.fetchSimilarTracksResult = .success([firstTrack, secondTrack])
		repository.fetchTrackInfoHandler = { track in
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
		let useCase = FetchSimilarTrackUseCaseImpl(trackRepository: repository)

		// when
		let tracks = try await useCase.execute(targetTrack: targetTrack)

		// then
		#expect(tracks[0].imageURL?.absoluteString == "https://image.test/1.jpg")
		#expect(tracks[1] == secondTrack)
	}
}
