//  MusicAppRouting.swift

import UIKit

protocol MusicAppRouting: AnyObject {
	var fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase { get }
}

extension MusicAppRouting {
	func openMusicApp(for track: Track) {
		Task {
			guard let url = await self.fetchMusicAppDeepLinkUseCase.execute(track: track) else { return }
			await MainActor.run {
				UIApplication.shared.open(url)
			}
		}
	}

	func openMusicApp(for artist: String) {
		Task {
			guard let url = await self.fetchMusicAppDeepLinkUseCase.execute(artist: artist) else { return }
			await MainActor.run {
				UIApplication.shared.open(url)
			}
		}
	}
}
