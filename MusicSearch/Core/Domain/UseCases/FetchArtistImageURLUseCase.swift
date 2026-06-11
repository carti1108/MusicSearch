//
//  FetchArtistImageURLUseCase.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation

public protocol FetchArtistImageURLUseCase: Sendable {
	func execute(artistName: String) async throws -> URL?
}

public final class FetchArtistImageURLUseCaseImpl: FetchArtistImageURLUseCase {
	private let artistImageRepository: ArtistImageRepository

	public init(artistImageRepository: ArtistImageRepository) {
		self.artistImageRepository = artistImageRepository
	}

	public func execute(artistName: String) async throws -> URL? {
		try await self.artistImageRepository.fetchImageURL(for: artistName)
	}
}
