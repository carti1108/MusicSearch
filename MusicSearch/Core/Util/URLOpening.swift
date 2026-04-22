//
//  URLOpening.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import UIKit

@MainActor
protocol URLOpening {
	func open(_ url: URL)
}

struct ApplicationURLOpener: URLOpening {
	func open(_ url: URL) {
		UIApplication.shared.open(url)
	}
}
