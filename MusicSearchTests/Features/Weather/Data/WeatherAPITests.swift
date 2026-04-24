import Foundation
import NetworkLayer
import Testing
@testable import MusicSearch

private struct StubWeatherAPIConfiguration: WeatherAPIConfiguration {
	let baseURL: String
	let apiPath: String
	let apiKey: String
	let units: String
}

struct WeatherAPITests {
	@Test
	func fetchWeather요청을생성하면_baseURL경로와쿼리파라미터가설정되는지() {
		let config = StubWeatherAPIConfiguration(
			baseURL: "https://weather.test",
			apiPath: "/current",
			apiKey: "weather-key",
			units: "metric"
		)
		let request = WeatherAPI.fetchWeather(lat: 37.5, lon: 127.0, config: config)

		#expect(request.baseURL.absoluteString == "https://weather.test")
		#expect(request.path == "/current")
		#expect(request.method == .get)
		#expect(request.cachePolicy == .memory)

		guard case let .requestParameters(parameters, encoding) = request.task else {
			Issue.record("쿼리 파라미터 요청이어야 합니다.")
			return
		}

		#expect(parameters["lat"] as? Double == 37.5)
		#expect(parameters["lon"] as? Double == 127.0)
		#expect(parameters["appid"] as? String == "weather-key")
		#expect(parameters["units"] as? String == "metric")
		#expect(String(describing: encoding) == String(describing: URLQueryEncoder()))
	}
}
