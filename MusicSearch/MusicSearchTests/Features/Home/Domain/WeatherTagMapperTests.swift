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
	
	@Test("thunderstorm은 정해진 태그 셋 중 하나로 매핑되는가")
	func mapThunderstorm() {
		// Given
		let condition: WeatherCondition = .thunderstorm
		let expectedTags = ["rock", "metal", "dark ambient", "storm"]
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(expectedTags.contains(tag))
	}
	
	@Test("drizzle은 정해진 태그 셋 중 하나로 매핑되는가")
	func mapDrizzle() {
		// Given
		let condition: WeatherCondition = .drizzle
		let expectedTags = ["acoustic", "chill", "folk", "mellow"]
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(expectedTags.contains(tag))
	}
	
	@Test("rain은 정해진 태그 셋 중 하나로 매핑되는가")
	func mapRain() {
		// Given
		let condition: WeatherCondition = .rain
		let expectedTags = ["jazz", "blues", "lofi", "piano", "sad"]
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(expectedTags.contains(tag))
	}
	
	@Test("snow는 정해진 태그 셋 중 하나로 매핑되는가")
	func mapSnow() {
		// Given
		let condition: WeatherCondition = .snow
		let expectedTags = ["christmas", "classical", "winter", "ambient"]
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(expectedTags.contains(tag))
	}
	
	@Test("atmosphere는 정해진 태그 셋 중 하나로 매핑되는가")
	func mapAtmosphere() {
		// Given
		let condition: WeatherCondition = .atmosphere
		let expectedTags = ["dream pop", "shoegaze", "ambient", "electronic"]
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(expectedTags.contains(tag))
	}
	
	@Test("clear는 정해진 태그 셋 중 하나로 매핑되는가")
	func mapClear() {
		// Given
		let condition: WeatherCondition = .clear
		let expectedTags = ["pop", "dance", "summer", "happy", "driving"]
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(expectedTags.contains(tag))
	}
	
	@Test("clouds는 정해진 태그 셋 중 하나로 매핑되는가")
	func mapClouds() {
		// Given
		let condition: WeatherCondition = .clouds
		let expectedTags = ["indie", "r&b", "soul", "soft pop"]
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(expectedTags.contains(tag))
	}
	
	@Test("unknown은 항상 pop으로 매핑되는가")
	func mapUnknown() {
		// Given
		let condition: WeatherCondition = .unknown
		
		// When
		let tag = mapper.map(condition: condition)
		
		// Then
		#expect(tag == "pop")
	}
}

