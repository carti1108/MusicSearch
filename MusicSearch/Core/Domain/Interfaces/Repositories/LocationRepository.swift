//
//  LocationRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import Foundation

protocol LocationRepository {
	func fetchCurrentLocation() async throws -> (latitude: Double, longitude: Double)
}
