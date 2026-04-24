//
//  WeatherTagMapperTests.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/7/25.
//

import Testing
import Foundation
@testable import MusicSearch

struct WeatherTagMapperTests {

	var mapper: WeatherTagMapper

	init() {
		self.mapper = WeatherTagMapper()
	}

	@Test
	func 날씨가Thunderstorm일때_map하면_매핑된태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .thunderstorm
		let expectedTags = ["rock", "metal", "dark ambient", "storm"]

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(expectedTags.contains(tag))
	}

	@Test
	func 날씨가Drizzle일때_map하면_매핑된태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .drizzle
		let expectedTags = ["acoustic", "chill", "folk", "mellow"]

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(expectedTags.contains(tag))
	}

	@Test
	func 날씨가Rain일때_map하면_매핑된태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .rain
		let expectedTags = ["jazz", "blues", "lofi", "piano", "sad"]

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(expectedTags.contains(tag))
	}

	@Test
	func 날씨가Snow일때_map하면_매핑된태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .snow
		let expectedTags = ["christmas", "classical", "winter", "ambient"]

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(expectedTags.contains(tag))
	}

	@Test
	func 날씨가Atmosphere일때_map하면_매핑된태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .atmosphere
		let expectedTags = ["dream pop", "shoegaze", "ambient", "electronic"]

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(expectedTags.contains(tag))
	}

	@Test
	func 날씨가Clear일때_map하면_매핑된태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .clear
		let expectedTags = ["pop", "dance", "summer", "happy", "driving"]

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(expectedTags.contains(tag))
	}

	@Test
	func 날씨가Clouds일때_map하면_매핑된태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .clouds
		let expectedTags = ["indie", "r&b", "soul", "soft pop"]

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(expectedTags.contains(tag))
	}

	@Test
	func 알수없는날씨일때_map하면_기본태그를반환하는지() {
		// Given
		let condition: WeatherCondition = .unknown

		// When
		let tag = mapper.map(condition: condition)

		// Then
		#expect(tag == "pop")
	}
}

