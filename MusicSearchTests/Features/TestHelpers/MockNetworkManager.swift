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
	/// Last.fm 처럼 같은 매니저로 여러 endpoint를 호출하는 케이스 대응용
	/// (queryParameters["method"] 기준)
	var resultDTOByMethod: [String: Decodable] = [:]
	var errorToThrow: Error?

	func request<Response: Decodable>(
		with requestable: any Requestable,
		as type: Response.Type
	) async throws -> Response {

		if let error = errorToThrow {
			throw error
		}

		let result: Decodable? = {
			if let method = requestable.queryParameters?["method"] as? String,
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
