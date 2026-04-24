import Foundation
@testable import MusicSearch

@MainActor
final class SpyWeatherRecommendationView: WeatherRecommendationPresentable {
	weak var listener: WeatherRecommendationPresentableListener?
	var updatedWeathers: [Weather] = []
	var updatedTracksHistory: [[Track]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func update(weather: Weather, tracks: [Track]) {
		self.updatedWeathers.append(weather)
		self.updatedTracksHistory.append(tracks)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
final class SpyTrackSearchView: TrackSearchPresentable {
	weak var listener: TrackSearchPresentableListener?
	var updatedTracksHistory: [[Track]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func updateTracks(_ tracks: [Track]) {
		self.updatedTracksHistory.append(tracks)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
final class SpyMusicDiggingView: MusicDiggingPresentable {
	weak var listener: MusicDiggingPresentableListener?
	var seedTrackHistory: [Track] = []
	var recommendationHistory: [[Track]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func updateSeedTrack(_ track: Track) {
		self.seedTrackHistory.append(track)
	}

	func updateRecommendations(_ tracks: [Track]) {
		self.recommendationHistory.append(tracks)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}

@MainActor
final class SpyChartView: ChartPresentable {
	weak var listener: ChartPresentableListener?
	var updatedSegments: [Int] = []
	var podiumHistory: [[ChartItem]] = []
	var listHistory: [[ChartItem]] = []
	var loadingStates: [Bool] = []
	var errorMessages: [String?] = []

	func updateSegment(to index: Int) {
		self.updatedSegments.append(index)
	}

	func update(podiumItems: [ChartItem], listItems: [ChartItem]) {
		self.podiumHistory.append(podiumItems)
		self.listHistory.append(listItems)
	}

	func showLoading(_ isShow: Bool) {
		self.loadingStates.append(isShow)
	}

	func showError(_ message: String?) {
		self.errorMessages.append(message)
	}
}
