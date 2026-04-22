//
//  MockURLOpener.swift
//  MusicSearchTests
//
//  Created by Kiseok on 4/22/26.
//

import Foundation
@testable import MusicSearch

@MainActor
final class MockURLOpener: URLOpening {
	var openedURLs: [URL] = []

	func open(_ url: URL) {
		self.openedURLs.append(url)
	}
}
