//  MusicAppRouting.swift

import UIKit

@MainActor
protocol MusicAppRouting: AnyObject {
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

extension MusicAppRouting {
	func openMusicApp(for track: Track) {
		let useCase = self.fetchMusicAppDeepLinkUseCase
		Task { @MainActor in
			guard let url = await useCase.execute(track: track) else { return }
			await UIApplication.shared.open(url)
		}
	}

	func openMusicApp(for artist: String) {
		let useCase = self.fetchMusicAppDeepLinkUseCase
		Task { @MainActor in
			guard let url = await useCase.execute(artist: artist) else { return }
			await UIApplication.shared.open(url)
		}
	}
}
