//
//  FetchTracksByTagUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchTracksByTagUseCase {
	func execute(tag: String) async throws -> [Track]
}
