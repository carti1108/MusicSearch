//
//  GetArtistTimelineUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol GetArtistTimelineUseCase {
	func execute(artist: Artist) async throws -> [Album]
}
