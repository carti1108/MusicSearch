//
//  FetchSimilarTrackUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol FetchSimilarTracksUseCase {
	func execute(targetTrack: Track) async throws -> [Track]
}
