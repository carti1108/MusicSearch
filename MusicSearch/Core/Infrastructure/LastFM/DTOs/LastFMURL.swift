//
//  LastFMURL.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

public enum LastFMURL {
	public static func imageURL(from raw: String?) -> URL? {
		let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }

		if trimmed.contains("2a96cbd8b46e442fc41c2b86b821562f") {
			return nil
		}

		return url.forcedHTTPS
	}
}
