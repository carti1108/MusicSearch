//
//  HomeDependency.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation

protocol HomeDependency: Dependency {
	var fetchCurrentWeatherUseCase: FetchCurrentWeatherUseCase { get }
	var fetchTracksByTagUseCase: FetchTracksByTagUseCase { get }
}

