//
//  LastFMURL.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

enum LastFMURL {
	static func imageURL(from raw: String?) -> URL? {
		let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }
		return url.forcedHTTPS
	}
}
