//
//  FetchArtistImageURLUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation

protocol FetchArtistImageURLUseCase: Sendable {
	func execute(artistName: String) async throws -> URL?
}

final class FetchArtistImageURLUseCaseImpl: FetchArtistImageURLUseCase {
	private let artistImageRepository: ArtistImageRepository

	init(artistImageRepository: ArtistImageRepository) {
		self.artistImageRepository = artistImageRepository
	}

	func execute(artistName: String) async throws -> URL? {
		try await self.artistImageRepository.fetchImageURL(for: artistName)
	}
}
