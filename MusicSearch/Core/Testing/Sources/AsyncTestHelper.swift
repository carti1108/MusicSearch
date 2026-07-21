//
//  AsyncTestHelper.swift
//  MusicSearch
//
//  Created by Kiseok on 7/18/26.
//

import Foundation

@MainActor
public enum AsyncTestHelper {
	public static func pause(for duration: Duration = .milliseconds(20)) async {
		try? await Task.sleep(for: duration)
	}

	public static func waitUntil(
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
public func waitUntil(
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
