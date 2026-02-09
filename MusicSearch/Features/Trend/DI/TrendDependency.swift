//
//  TrendDependency.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

protocol TrendDependency: Dependency {
	var fetchChartTopTracksUseCase: FetchChartTopTracksUseCase { get }

	var fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase { get }
	
	var spotifyService: SpotifyServiceProtocol { get }
}
