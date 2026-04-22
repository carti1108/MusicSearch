//
//  MockURLOpener.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/22/26.
//

import Foundation
@testable import MusicSearch

final class MockURLOpener: URLOpening {
	var openedURLs: [URL] = []

	@MainActor
	func open(_ url: URL) {
		self.openedURLs.append(url)
	}
}
