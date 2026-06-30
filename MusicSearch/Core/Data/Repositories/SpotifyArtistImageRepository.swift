//
//  SpotifyArtistImageRepository.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import Foundation
import NetworkLayer
import MSDomain
import MSUtil

public actor SpotifyArtistImageRepository: ArtistImageRepository {

	private let configuration: SpotifyAPIConfiguration
	private let networkManager: NetworkRequesting
	private let authRepository: SpotifyAuthRepository

	private enum SpotifyRepositoryError: Error {
		case invalidURL
		case unauthorized
	}

	public init(
		configuration: SpotifyAPIConfiguration = DefaultSpotifyAPIConfiguration(),
		networkManager: NetworkRequesting,
		authRepository: SpotifyAuthRepository
	) {
		self.configuration = configuration
		self.networkManager = networkManager
		self.authRepository = authRepository
	}

	public func fetchImageURL(for artistName: String) async throws -> URL? {
		let token = try await self.getAccessToken()
		return try await self.fetchImageURL(artistName: artistName, token: token)
	}

	private func getAccessToken() async throws -> String {
		if let token = authRepository.getAccessToken() {
			return token
		}

		do {
			return try await authRepository.getClientCredentialsToken()
		} catch {
			throw SpotifyRepositoryError.unauthorized
		}
	}

	private func fetchImageURL(artistName: String, token: String) async throws -> URL? {
		let api = SpotifyAPI.artistSearch(
			query: self.artistSearchQuery(for: artistName),
			token: token,
			limit: 1,
			config: self.configuration
		)
		let searchResponse = try await self.networkManager.perform(
			with: api,
			as: SpotifyArtistImageSearchResponseDTO.self
		)

		return self.bestArtistImageURL(from: searchResponse.artists.items)
	}

	private func artistSearchQuery(for artistName: String) -> String {
		let sanitizedName = artistName.replacingOccurrences(of: "\"", with: "")
		return sanitizedName
	}

	private func bestArtistImageURL(from items: [SpotifyArtistImageItemDTO]) -> URL? {
		guard let selectedArtist = items.first else { return nil }
		return self.bestImageURL(from: selectedArtist.images)
	}

	private func bestImageURL(from images: [SpotifyImageDTO]) -> URL? {
		let selectedImage = images.max { lhs, rhs in
			(lhs.width ?? 0) < (rhs.width ?? 0)
		}

		guard let selectedImage,
			  let url = URL(string: selectedImage.url) else {
			return nil
		}
		return url.forcedHTTPS
	}

}
