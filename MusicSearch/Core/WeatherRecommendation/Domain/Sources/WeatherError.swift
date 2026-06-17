import MSDomain
//
//  WeatherError.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

public enum WeatherError: Error, Equatable {
	case locationPermissionDenied
	case locationFetchFailed
	case configurationError
	case networkError(String)
	case unknown
}

extension WeatherError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .locationPermissionDenied:
			return "위치 권한이 필요합니다. 설정에서 권한을 허용해 주세요."
		case .locationFetchFailed:
			return "현재 위치를 찾을 수 없습니다. GPS 설정을 확인해 주세요."
		case .configurationError:
			return "앱 설정에 오류가 있습니다. 다시 시작해 주세요"
		case .networkError(let message):
			return "날씨 정보를 불러오는데 실패했습니다. (\(message))"
		case .unknown:
			return "알 수 없는 오류가 발생했습니다."
		}
	}
}
