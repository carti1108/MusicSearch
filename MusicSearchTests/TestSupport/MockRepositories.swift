import Foundation
import CoreLocation
import NetworkLayer
@testable import MusicSearch

enum TestDoubleError: Error, Equatable {
	case missingStubbedValue(String)
	case mismatchedStubbedType(expected: String, actual: String)
}

final class MockNetworkManager: NetworkRequesting, @unchecked Sendable {
	var resultDTO: Decodable?
	var resultDTOByMethod: [String: Decodable] = [:]
	var resultDTOByType: [String: Decodable] = [:]
	var errorToThrow: Error?
	var requestedMethods: [String] = []

	func perform<Response: Decodable>(
		with requestable: some Requestable,
		as type: Response.Type
	) async throws -> Response {
		if let errorToThrow {
			throw errorToThrow
		}

		let queryParameters: [String: Any]? = {
			if case let .requestParameters(parameters, _) = requestable.task {
				return parameters
			}
			return nil
		}()

		if let method = queryParameters?["method"] as? String {
			self.requestedMethods.append(method)
		}

		let storedDTO: Decodable?
		if let method = queryParameters?["method"] as? String,
		   let dto = self.resultDTOByMethod[method] {
			storedDTO = dto
		} else if let dto = self.resultDTOByType[String(describing: Response.self)] {
			storedDTO = dto
		} else {
			storedDTO = self.resultDTO
		}

		guard let storedDTO else {
			throw TestDoubleError.missingStubbedValue("MockNetworkManager.resultDTO")
		}

		guard let typedResult = storedDTO as? Response else {
			throw TestDoubleError.mismatchedStubbedType(
				expected: String(describing: Response.self),
				actual: String(describing: Swift.type(of: storedDTO))
			)
		}

		return typedResult
	}
}

final class MockTrackRepository: TrackRepository, @unchecked Sendable {
	var searchTracksResult: Result<(tracks: [Track], totalResults: Int), Error> = .success(([], 0))
	var fetchTopTracksResult: Result<[Track], Error> = .success([])
	var fetchSimilarTracksResult: Result<[Track], Error> = .success([])
	var fetchTrackInfoResult: Result<Track, Error> = .success(
		Track(title: "Mock Track", artist: "Mock Artist", imageURL: nil)
	)

	var searchTracksHandler: ((String, Int, Int) async throws -> (tracks: [Track], totalResults: Int))?
	var fetchTopTracksHandler: ((String) async throws -> [Track])?
	var fetchSimilarTracksHandler: ((Track) async throws -> [Track])?
	var fetchTrackInfoHandler: ((Track) async throws -> Track)?

	var searchTracksCallCount = 0
	var fetchTopTracksCallCount = 0
	var fetchSimilarTracksCallCount = 0
	var fetchTrackInfoCallCount = 0

	var lastSearchTracksQuery: String?
	var lastSearchTracksLimit: Int?
	var lastSearchTracksPage: Int?
	var lastFetchTopTracksTag: String?
	var lastFetchSimilarTracksTrack: Track?
	var lastFetchTrackInfoTrack: Track?

	var searchTracksRequests: [(query: String, limit: Int, page: Int)] = []
	var fetchTrackInfoRequests: [Track] = []

	func searchTracks(query: String, limit: Int, page: Int) async throws -> (tracks: [Track], totalResults: Int) {
		self.searchTracksCallCount += 1
		self.lastSearchTracksQuery = query
		self.lastSearchTracksLimit = limit
		self.lastSearchTracksPage = page
		self.searchTracksRequests.append((query, limit, page))

		if let searchTracksHandler {
			return try await searchTracksHandler(query, limit, page)
		}

		switch self.searchTracksResult {
		case .success(let result):
			return result
		case .failure(let error):
			throw error
		}
	}

	func fetchTopTracks(by tag: String) async throws -> [Track] {
		self.fetchTopTracksCallCount += 1
		self.lastFetchTopTracksTag = tag

		if let fetchTopTracksHandler {
			return try await fetchTopTracksHandler(tag)
		}

		switch self.fetchTopTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}

	func fetchSimilarTracks(to track: Track) async throws -> [Track] {
		self.fetchSimilarTracksCallCount += 1
		self.lastFetchSimilarTracksTrack = track

		if let fetchSimilarTracksHandler {
			return try await fetchSimilarTracksHandler(track)
		}

		switch self.fetchSimilarTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}

	func fetchTrackInfo(for track: Track) async throws -> Track {
		self.fetchTrackInfoCallCount += 1
		self.lastFetchTrackInfoTrack = track
		self.fetchTrackInfoRequests.append(track)

		if let fetchTrackInfoHandler {
			return try await fetchTrackInfoHandler(track)
		}

		switch self.fetchTrackInfoResult {
		case .success(let track):
			return track
		case .failure(let error):
			throw error
		}
	}
}

final class MockChartRepository: ChartRepository {
	var fetchTopTracksResult: Result<[Track], Error> = .success([])
	var fetchTopArtistsResult: Result<[Artist], Error> = .success([])
	var fetchTopTracksHandler: (() async throws -> [Track])?
	var fetchTopArtistsHandler: (() async throws -> [Artist])?

	var fetchTopTracksCallCount = 0
	var fetchTopArtistsCallCount = 0

	func fetchTopTracks() async throws -> [Track] {
		self.fetchTopTracksCallCount += 1

		if let fetchTopTracksHandler {
			return try await fetchTopTracksHandler()
		}

		switch self.fetchTopTracksResult {
		case .success(let tracks):
			return tracks
		case .failure(let error):
			throw error
		}
	}

	func fetchTopArtists() async throws -> [Artist] {
		self.fetchTopArtistsCallCount += 1

		if let fetchTopArtistsHandler {
			return try await fetchTopArtistsHandler()
		}

		switch self.fetchTopArtistsResult {
		case .success(let artists):
			return artists
		case .failure(let error):
			throw error
		}
	}
}

final class MockMusicAppRepository: MusicAppRepository {
	var trackURLToReturn: URL?
	var artistURLToReturn: URL?
	var trackHandler: ((Track) async -> URL?)?
	var artistHandler: ((String) async -> URL?)?

	private(set) var fetchTrackDeepLinkCallCount = 0
	private(set) var fetchArtistDeepLinkCallCount = 0
	private(set) var receivedTrack: Track?
	private(set) var receivedArtist: String?

	func fetchDeepLink(for track: Track) async -> URL? {
		self.fetchTrackDeepLinkCallCount += 1
		self.receivedTrack = track

		if let trackHandler {
			return await trackHandler(track)
		}

		return self.trackURLToReturn
	}

	func fetchDeepLink(for artist: String) async -> URL? {
		self.fetchArtistDeepLinkCallCount += 1
		self.receivedArtist = artist

		if let artistHandler {
			return await artistHandler(artist)
		}

		return self.artistURLToReturn
	}
}

final class MockWeatherRepository: WeatherRepository {
	var result: Weather?
	var errorToThrow: Error?
	var receivedLat: Double?
	var receivedLon: Double?

	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> Weather {
		self.receivedLat = latitude
		self.receivedLon = longitude

		if let errorToThrow {
			throw errorToThrow
		}

		if let result {
			return result
		}

		throw TestDoubleError.missingStubbedValue("MockWeatherRepository.result")
	}
}

final class MockLocationRepository: LocationRepository {
	var result: (latitude: Double, longitude: Double)?
	var errorToThrow: Error?

	func fetchCurrentLocation() async throws -> (latitude: Double, longitude: Double) {
		if let errorToThrow {
			throw errorToThrow
		}

		if let result {
			return result
		}

		throw TestDoubleError.missingStubbedValue("MockLocationRepository.result")
	}
}

final class MockLocationManager: LocationManaging {
	var authorizationStatus: CLAuthorizationStatus = .notDetermined
	var desiredAccuracy: CLLocationAccuracy = 0
	var isRequestPermissionCalled = false
	var locationToReturn: CLLocation?
	var errorToThrow: Error?
	var delay: Duration = .seconds(0)

	func requestWhenInUseAuthorization() {
		self.isRequestPermissionCalled = true
	}

	func requestLocation() async throws -> CLLocation {
		if self.delay > .seconds(0) {
			try await Task.sleep(for: self.delay)
		}

		if let errorToThrow {
			throw errorToThrow
		}

		if let locationToReturn {
			return locationToReturn
		}

		throw WeatherError.unknown
	}
}

struct MockWeatherConfiguration: WeatherAPIConfiguration {
	var baseURL: String = "https://test.api.com"
	var apiPath: String = "/test"
	var apiKey: String = "TEST_KEY"
	var units: String = "metric"
}
