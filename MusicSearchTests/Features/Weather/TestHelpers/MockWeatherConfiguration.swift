//
//  MockWeatherConfiguration.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/6/25.
//

import Foundation
import Testing
@testable import MusicSearch

struct MockWeatherConfiguration: WeatherAPIConfiguration {
	var baseURL: String = "https://test.api.com"
	var apiPath: String = "/test"
	var apiKey: String = "TEST_KEY"
	var units: String = "metric"
}
