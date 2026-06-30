//
//  URLOpening.swift
//  MusicSearch
//
//  Created by Kiseok on 4/22/26.
//

import UIKit

public protocol URLOpening {
	@MainActor
	func open(_ url: URL)
}

public struct ApplicationURLOpener: URLOpening {

	public init() {}

	@MainActor
	public func open(_ url: URL) {
		UIApplication.shared.open(url)
	}
}
