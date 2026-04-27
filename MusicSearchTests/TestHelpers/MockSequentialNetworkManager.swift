import Foundation
import NetworkLayer
@testable import MusicSearch

final class MockSequentialNetworkManager: NetworkRequesting, @unchecked Sendable {

	private var responseQueues: [String: [Decodable]] = [:]
	private var errors: [String: [Error]] = [:]
	var totalCallCount = 0
	var typeCallCounts: [String: Int] = [:]

	func enqueue<T: Decodable>(_ response: T, forType type: T.Type = T.self) {
		let key = String(describing: T.self)
		responseQueues[key, default: []].append(response)
	}

	func enqueueError(_ error: Error, forType typeName: String) {
		errors[typeName, default: []].append(error)
	}

	func callCount<T>(for type: T.Type) -> Int {
		typeCallCounts[String(describing: T.self)] ?? 0
	}

	func perform<Response: Decodable>(
		with requestable: some Requestable,
		as type: Response.Type
	) async throws -> Response {
		totalCallCount += 1
		let key = String(describing: Response.self)
		typeCallCounts[key, default: 0] += 1

		if var errorQueue = errors[key], !errorQueue.isEmpty {
			let error = errorQueue.removeFirst()
			errors[key] = errorQueue
			throw error
		}

		guard var queue = responseQueues[key], !queue.isEmpty else {
			throw TestDoubleError.missingStubbedValue("MockSequentialNetworkManager: \(key)")
		}

		let response = queue.removeFirst()
		responseQueues[key] = queue

		guard let typed = response as? Response else {
			throw TestDoubleError.mismatchedStubbedType(
				expected: key,
				actual: String(describing: Swift.type(of: response))
			)
		}
		return typed
	}
}
