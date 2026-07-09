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
	private let artistImageService: ArtistImageService

	public init(artistImageService: ArtistImageService) {
		self.artistImageService = artistImageService
	}

	public func execute(artistName: String) async throws -> URL? {
		try await self.artistImageService.fetchImageURL(for: artistName)
	}
}
