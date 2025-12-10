//
//  MusicComponent.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation

final class MusicComponent<T: MusicDependency>: Component {

	typealias DependencyType = T

	private let dependency: T

	init(dependency: T) {
		self.dependency = dependency
	}

	var musicRepository: MusicRepository {
		MusicRepositoryImpl(networkManager: dependency.networkManager)
	}

	var fetchTracksByTagUseCase: FetchTracksByTagUseCase {
		FetchTracksByTagUseCaseImpl(musicRepository: musicRepository)
	}

	var searchTracksUseCase: SearchTracksUseCase {
		SearchTrackUseCaseImpl(musicRepository: musicRepository)
	}

	var searchArtistUseCase: SearchArtistsUseCase {
		SearchArtistUseCaseImpl(musicRepository: musicRepository)
	}

	var fetchSimilarTrackUseCase: FetchSimilarTracksUseCase {
		FetchSimilarTrackUseCaseImpl(musicRepository: musicRepository)
	}

	var getArtistTimelineUseCase: GetArtistTimelineUseCase {
		GetArtistTimelineUseCaseImpl(musicRepository: musicRepository)
	}
}

