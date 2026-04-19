import Foundation
@testable import MusicSearch

@MainActor
enum AsyncTestHelper {
	static func pause(for duration: Duration = .milliseconds(20)) async {
		try? await Task.sleep(for: duration)
	}

	static func waitUntil(
		timeout: Duration = .seconds(1),
		pollInterval: Duration = .milliseconds(10),
		condition: @escaping () -> Bool
	) async -> Bool {
		let clock = ContinuousClock()
		let deadline = clock.now.advanced(by: timeout)

		while clock.now < deadline {
			if condition() {
				return true
			}

			try? await Task.sleep(for: pollInterval)
		}

		return condition()
	}
}
