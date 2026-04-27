import Testing
import Foundation
import NetworkLayer
@testable import MusicSearch

struct WeatherAPITests {

	let config = MockWeatherConfiguration()

	@Test
	func fetchWeather케이스일때_baseURL에접근하면_설정된URL을반환하는지() {
		// given
		let api = WeatherAPI.fetchWeather(lat: 37.5, lon: 127.0, config: config)

		// then
		#expect(api.baseURL.absoluteString == "https://test.api.com")
	}

	@Test
	func fetchWeather케이스일때_path에접근하면_설정된apiPath를반환하는지() {
		// given
		let api = WeatherAPI.fetchWeather(lat: 37.5, lon: 127.0, config: config)

		// then
		#expect(api.path == "/test")
	}

	@Test
	func fetchWeather케이스일때_method에접근하면_GET을반환하는지() {
		// given
		let api = WeatherAPI.fetchWeather(lat: 37.5, lon: 127.0, config: config)

		// then
		#expect(api.method == .get)
	}

	@Test
	func fetchWeather케이스일때_headers에접근하면_nil을반환하는지() {
		// given
		let api = WeatherAPI.fetchWeather(lat: 37.5, lon: 127.0, config: config)

		// then
		#expect(api.headers == nil)
	}

	@Test
	func fetchWeather케이스일때_cachePolicy에접근하면_memory를반환하는지() {
		// given
		let api = WeatherAPI.fetchWeather(lat: 37.5, lon: 127.0, config: config)

		// then
		#expect(api.cachePolicy == .memory)
	}

	@Test
	func fetchWeather케이스일때_task에접근하면_좌표와apiKey와units파라미터가포함되는지() {
		// given
		let api = WeatherAPI.fetchWeather(lat: 37.5, lon: 127.0, config: config)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["lat"] as? Double == 37.5)
		#expect(params["lon"] as? Double == 127.0)
		#expect(params["appid"] as? String == "TEST_KEY")
		#expect(params["units"] as? String == "metric")
	}

	@Test
	func 다른좌표로fetchWeather케이스를생성할때_task에접근하면_해당좌표가반영되는지() {
		// given
		let api = WeatherAPI.fetchWeather(lat: -33.9, lon: 151.2, config: config)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["lat"] as? Double == -33.9)
		#expect(params["lon"] as? Double == 151.2)
	}

	@Test
	func 커스텀apiKey가설정될때_fetchWeather케이스의task에접근하면_해당apiKey가반영되는지() {
		// given
		var customConfig = MockWeatherConfiguration()
		customConfig.apiKey = "CUSTOM_KEY"
		let api = WeatherAPI.fetchWeather(lat: 0, lon: 0, config: customConfig)

		// when
		guard case let .requestParameters(params, _) = api.task else {
			Issue.record("task가 requestParameters가 아님")
			return
		}

		// then
		#expect(params["appid"] as? String == "CUSTOM_KEY")
	}
}
