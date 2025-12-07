//
//  SearchTracksUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol SearchTracksUseCase {
	func execute(query: String) async throws -> [Track]
}
