//
//  SearchArtistUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public protocol SearchArtistsUseCase {
	func execute(query: String) async throws -> [Artist]
}
