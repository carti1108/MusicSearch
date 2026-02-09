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

final class MockNetworkManager: NetworkRequesting {

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
			 fatalError("Mock: 결과 데이터가 설정되지 않았습니다.")
		}

		guard let typedResult = result as? Response else {
			fatalError("Mock: 요청한 타입과 저장된 데이터의 타입이 일치하지 않습니다.")
		}

		return typedResult
	}
}
