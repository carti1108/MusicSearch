//
//  MockNetworkManager.swift
//  MusicSearchTests
//
//  Created by Kiseok on 12/6/25.
//

import Foundation
import Testing
import NetworkLayer
@testable import MusicSearch

final class MockNetworkManager: NetworkRequesting, @unchecked Sendable {

	enum MockError: Error {
		case missingStub
		case typeMismatch(expected: Any.Type, actual: Any.Type)
	}

	var resultDTO: Decodable?
	var resultDTOByMethod: [String: Decodable] = [:]
	var errorToThrow: Error?

	func perform<Response: Decodable>(
		with requestable: some Requestable,
		as type: Response.Type
	) async throws -> Response {

		if let error = errorToThrow {
			throw error
		}

		let result: Decodable? = {
			var queryParameters: [String: Any]?
			if case let .requestParameters(parameters, _) = requestable.task {
				queryParameters = parameters
			}

			if let method = queryParameters?["method"] as? String,
			   let dto = self.resultDTOByMethod[method] {
				return dto
			}
			return self.resultDTO
		}()

		guard let result = result else {
			throw MockError.missingStub
		}

		guard let typedResult = result as? Response else {
			throw MockError.typeMismatch(expected: Response.self, actual: Swift.type(of: result))
		}

		return typedResult
	}
}
