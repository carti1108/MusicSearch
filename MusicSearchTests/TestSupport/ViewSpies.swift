import Foundation
@testable import MusicSearch

@MainActor
final class SpyWeatherRecommendationView: WeatherRecommendationViewable {
	var listener: WeatherRecommendationViewableListener?
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
final class SpyWeatherRecommendationCoordinator: WeatherRecommendationCoordinatorAction {
	var selectedTracks: [Track] = []

	func didSelect(track: Track) {
		self.selectedTracks.append(track)
	}
}

@MainActor
final class SpyTrackSearchView: TrackSearchViewable {
	var listener: TrackSearchViewableListener?
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
final class SpyTrackSearchCoordinator: TrackSearchViewCoordinatorAction {
	var selectedTracks: [Track] = []

	func didSelect(_ track: Track) {
		self.selectedTracks.append(track)
	}
}

@MainActor
final class SpyMusicDiggingView: MusicDiggingViewable {
	var listener: MusicDiggingViewableListener?
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
final class SpyMusicDiggingCoordinator: MusicDiggingViewCoordinatorAction {
	var tappedSeedTracks: [Track] = []

	func didTapSeedTrack(_ track: Track) {
		self.tappedSeedTracks.append(track)
	}
}

@MainActor
final class SpyChartView: ChartViewable {
	var listener: ChartViewableListener?
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

@MainActor
final class SpyChartCoordinator: ChartViewCoordinatorAction {
	var selectedItems: [ChartItem] = []

	func didSelect(item: ChartItem) {
		self.selectedItems.append(item)
	}
}
