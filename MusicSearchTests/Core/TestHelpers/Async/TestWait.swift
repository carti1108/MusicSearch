import Foundation
import Testing

@MainActor
func waitUntil(
	_ message: String = "조건이 시간 내에 충족되지 않았습니다.",
	timeout: Duration = .seconds(1),
	pollLimit: Int = 50,
	condition: () -> Bool
) async {
	guard pollLimit > 0 else {
		Issue.record(Comment(rawValue: "waitUntil: pollLimit은 1 이상이어야 합니다."))
		return
	}

	let clock = ContinuousClock()
	let deadline = clock.now.advanced(by: timeout)
	var pollCount = 0

	while clock.now < deadline {
		if condition() { return }
		pollCount += 1
		if pollCount >= pollLimit { break }
		try? await Task.sleep(for: .milliseconds(10))
	}

	Issue.record(Comment(rawValue: message))
}

