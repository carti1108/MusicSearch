//
//  WeatherTagMapper.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

struct WeatherTagMapper {

	func map(condition: WeatherCondition) -> String {
		switch condition {
		case .thunderstorm:
			return ["rock", "metal", "dark ambient", "storm"].randomElement() ?? "rock"

		case .drizzle:
			return ["acoustic", "chill", "folk", "mellow"].randomElement() ?? "acoustic"

		case .rain:
			return ["jazz", "blues", "lofi", "piano", "sad"].randomElement() ?? "jazz"

		case .snow:
			return ["christmas", "classical", "winter", "ambient"].randomElement() ?? "classical"

		case .atmosphere:
			return ["dream pop", "shoegaze", "ambient", "electronic"].randomElement() ?? "dream pop"

		case .clear:
			return ["pop", "dance", "summer", "happy", "driving"].randomElement() ?? "pop"

		case .clouds:
			return ["indie", "r&b", "soul", "soft pop"].randomElement() ?? "indie"

		case .unknown:
			return "pop"
		}
	}
}
