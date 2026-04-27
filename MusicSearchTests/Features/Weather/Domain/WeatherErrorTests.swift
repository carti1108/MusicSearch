import Testing
import Foundation
@testable import MusicSearch

struct WeatherErrorTests {

	@Test
	func locationPermissionDenied에러일때_errorDescription에접근하면_위치권한메시지를반환하는지() {
		// given
		let error = WeatherError.locationPermissionDenied

		// when
		let description = error.errorDescription

		// then
		#expect(description == "위치 권한이 필요합니다. 설정에서 권한을 허용해 주세요.")
	}

	@Test
	func locationFetchFailed에러일때_errorDescription에접근하면_GPS오류메시지를반환하는지() {
		// given
		let error = WeatherError.locationFetchFailed

		// when
		let description = error.errorDescription

		// then
		#expect(description == "현재 위치를 찾을 수 없습니다. GPS 설정을 확인해 주세요.")
	}

	@Test
	func configurationError에러일때_errorDescription에접근하면_설정오류메시지를반환하는지() {
		// given
		let error = WeatherError.configurationError

		// when
		let description = error.errorDescription

		// then
		#expect(description == "앱 설정에 오류가 있습니다. 다시 시작해 주세요")
	}

	@Test
	func networkError에러일때_errorDescription에접근하면_메시지가포함된문자열을반환하는지() {
		// given
		let error = WeatherError.networkError("timeout")

		// when
		let description = error.errorDescription

		// then
		#expect(description == "날씨 정보를 불러오는데 실패했습니다. (timeout)")
	}

	@Test
	func networkError메시지가빈문자열일때_errorDescription에접근하면_빈괄호가포함된메시지를반환하는지() {
		// given
		let error = WeatherError.networkError("")

		// when
		let description = error.errorDescription

		// then
		#expect(description == "날씨 정보를 불러오는데 실패했습니다. ()")
	}

	@Test
	func unknown에러일때_errorDescription에접근하면_알수없는오류메시지를반환하는지() {
		// given
		let error = WeatherError.unknown

		// when
		let description = error.errorDescription

		// then
		#expect(description == "알 수 없는 오류가 발생했습니다.")
	}

	@Test
	func 같은케이스의WeatherError일때_동등비교하면_동일하다고판단하는지() {
		// given
		let cases: [(WeatherError, WeatherError)] = [
			(.locationPermissionDenied, .locationPermissionDenied),
			(.locationFetchFailed, .locationFetchFailed),
			(.configurationError, .configurationError),
			(.unknown, .unknown),
			(.networkError("msg"), .networkError("msg"))
		]

		// then
		for (lhs, rhs) in cases {
			#expect(lhs == rhs)
		}
	}

	@Test
	func 다른메시지의networkError일때_동등비교하면_다르다고판단하는지() {
		// given
		let errorA = WeatherError.networkError("a")
		let errorB = WeatherError.networkError("b")

		// then
		#expect(errorA != errorB)
	}

	@Test
	func 다른케이스의WeatherError일때_동등비교하면_다르다고판단하는지() {
		// given
		let unknown = WeatherError.unknown
		let configError = WeatherError.configurationError
		let locationDenied = WeatherError.locationPermissionDenied
		let locationFailed = WeatherError.locationFetchFailed

		// then
		#expect(unknown != configError)
		#expect(locationDenied != locationFailed)
	}
}
