//
//  HomeDependency.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation

protocol HomeDependency: Dependency {
	var fetchMusicForWeatherUseCase: FetchMusicForWeatherUseCase { get }
	var spotifyService: SpotifyServiceProtocol { get }
}

