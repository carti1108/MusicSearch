//
//  LocationRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 12/5/25.
//

import MSDomain

import Foundation

public protocol LocationRepository: Sendable {
	func fetchCurrentLocation() async throws -> (latitude: Double, longitude: Double)
}
