import Foundation
import Testing
@testable import MusicSearch

private struct BlankLocalizedError: LocalizedError {
	let errorDescription: String? = "   "
}

private struct MessageLocalizedError: LocalizedError {
	let errorDescription: String? = "사용자 메시지"
}

struct UtilityTests {
	@Test
	func forcedHTTPS는_http스킴이면_https로강제변환하는지() {
		let url = URL(string: "http://image.test/a.jpg")!

		#expect(url.forcedHTTPS.absoluteString == "https://image.test/a.jpg")
	}

	@Test
	func forcedHTTPS는_https스킴이면_그대로반환하는지() {
		let url = URL(string: "https://image.test/a.jpg")!

		#expect(url.forcedHTTPS == url)
	}

	@Test
	func userMessage는_LocalizedError메시지가있으면그값을반환하는지() {
		let error = MessageLocalizedError()

		#expect(error.userMessage(fallback: "기본 메시지") == "사용자 메시지")
	}

	@Test
	func userMessage는_공백메시지면fallback을반환하는지() {
		let error = BlankLocalizedError()

		#expect(error.userMessage(fallback: "기본 메시지") == "기본 메시지")
	}

	@Test
	func WeatherError의localizedDescription이각케이스에맞는문구를반환하는지() {
		#expect(WeatherError.locationPermissionDenied.errorDescription?.contains("위치 권한") == true)
		#expect(WeatherError.locationFetchFailed.errorDescription?.contains("현재 위치") == true)
		#expect(WeatherError.configurationError.errorDescription?.contains("앱 설정") == true)
		#expect(WeatherError.networkError("Timeout").errorDescription?.contains("Timeout") == true)
		#expect(WeatherError.unknown.errorDescription?.contains("알 수 없는 오류") == true)
	}
}
