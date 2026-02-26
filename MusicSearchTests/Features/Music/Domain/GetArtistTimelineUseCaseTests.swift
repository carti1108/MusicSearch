//
//  GetArtistTimelineUseCaseTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
@testable import MusicSearch

struct FetchChartTopArtistsUseCaseTests {
	private final class MockChartRepository: ChartRepository {
		var topArtistsResult: Result<[Artist], Error> = .success([])

		func fetchTopTracks() async throws -> [Track] {
			return []
		}

		func fetchTopArtists() async throws -> [Artist] {
			try self.topArtistsResult.get()
		}
	}

	@Test("아티스트 차트 조회 유스케이스가 정상 동작하는가")
	func fetchChartTopArtistsSuccess() async throws {
		let repository = MockChartRepository()
		repository.topArtistsResult = .success([
			Artist(name: "Artist A", imageURL: nil),
			Artist(name: "Artist B", imageURL: nil)
		])

		let useCase = FetchChartTopArtistsUseCaseImpl(chartRepository: repository)
		let artists = try await useCase.execute()

		#expect(artists.count == 2)
		#expect(artists[0].name == "Artist A")
	}

	@Test("아티스트 차트 조회 시 repository 에러를 전파하는가")
	func fetchChartTopArtistsFailure() async {
		enum TestError: Error {
			case failed
		}
		let repository = MockChartRepository()
		repository.topArtistsResult = .failure(TestError.failed)

		let useCase = FetchChartTopArtistsUseCaseImpl(chartRepository: repository)
		await #expect(throws: TestError.self) {
			_ = try await useCase.execute()
		}
	}
}
