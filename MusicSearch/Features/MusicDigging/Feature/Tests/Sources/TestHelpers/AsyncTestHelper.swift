import Foundation

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

@MainActor
@discardableResult
func waitUntil(
	_ description: String = "",
	timeout: Duration = .seconds(1),
	pollInterval: Duration = .milliseconds(10),
	_ condition: @escaping () -> Bool
) async -> Bool {
	await AsyncTestHelper.waitUntil(
		timeout: timeout,
		pollInterval: pollInterval,
		condition: condition
	)
}
