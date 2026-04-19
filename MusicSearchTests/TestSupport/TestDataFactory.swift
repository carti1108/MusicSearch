import Foundation
@testable import MusicSearch

enum TestDataFactory {
	static func makeTrack(
		id: String = UUID().uuidString,
		mbid: String? = nil,
		title: String = "Test Track",
		artist: String = "Test Artist",
		imageURL: String? = nil
	) -> Track {
		Track(
			id: id,
			mbid: mbid,
			title: title,
			artist: artist,
			imageURL: imageURL.flatMap(URL.init(string:))
		)
	}

	static func makeArtist(
		id: String = UUID().uuidString,
		name: String = "Test Artist",
		imageURL: String? = nil,
		listeners: String? = nil,
		tags: [String] = [],
		bio: String? = nil
	) -> Artist {
		Artist(
			id: id,
			name: name,
			imageURL: imageURL.flatMap(URL.init(string:)),
			listeners: listeners,
			tags: tags,
			bio: bio
		)
	}

	static func makeWeather(
		temperature: Double = 20,
		condition: WeatherCondition = .clear,
		description: String = "맑음",
		iconCode: String = "01d",
		cityName: String = "Seoul"
	) -> Weather {
		Weather(
			temperature: temperature,
			condition: condition,
			description: description,
			iconCode: iconCode,
			cityName: cityName
		)
	}

	static func makeWeatherMusicCuration(
		weather: Weather = makeWeather(),
		moodTag: String = "pop",
		tracks: [Track] = []
	) -> WeatherMusicCuration {
		WeatherMusicCuration(weather: weather, moodTag: moodTag, tracks: tracks)
	}

	static func makeChartTrackDTO(
		name: String = "Chart Track",
		artist: String = "Chart Artist",
		mbid: String? = nil,
		imageURL: String? = nil
	) -> ChartTrackDTO {
		ChartTrackDTO(
			name: name,
			playcount: "100",
			listeners: "50",
			mbid: mbid,
			url: "https://last.fm/track/\(name)",
			artist: ChartTrackArtistDTO(
				name: artist,
				mbid: nil,
				url: "https://last.fm/artist/\(artist)"
			),
			image: self.makeImages(from: imageURL)
		)
	}

	static func makeChartTopTracksResponseDTO(tracks: [ChartTrackDTO]) -> ChartTopTracksResponseDTO {
		ChartTopTracksResponseDTO(tracks: ChartTrackListDTO(track: tracks))
	}

	static func makeChartArtistDTO(
		name: String = "Chart Artist",
		listeners: String = "1234",
		mbid: String? = nil,
		imageURL: String? = nil
	) -> ChartArtistDTO {
		ChartArtistDTO(
			name: name,
			playcount: "100",
			listeners: listeners,
			mbid: mbid,
			url: "https://last.fm/artist/\(name)",
			image: self.makeImages(from: imageURL)
		)
	}

	static func makeChartTopArtistsResponseDTO(artists: [ChartArtistDTO]) -> ChartTopArtistsResponseDTO {
		ChartTopArtistsResponseDTO(artists: ChartArtistListDTO(artist: artists))
	}

	private static func makeImages(from imageURL: String?) -> [LastFMImageDTO]? {
		guard let imageURL else { return nil }

		return [
			LastFMImageDTO(size: "small", text: ""),
			LastFMImageDTO(size: "extralarge", text: imageURL)
		]
	}
}
