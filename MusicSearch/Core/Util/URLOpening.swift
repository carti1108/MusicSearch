//
//  URLOpening.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import UIKit

protocol URLOpening {
	@MainActor
	func open(_ url: URL)
}

struct ApplicationURLOpener: URLOpening {
	@MainActor
	func open(_ url: URL) {
		UIApplication.shared.open(url)
	}
}
