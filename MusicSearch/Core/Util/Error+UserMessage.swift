//
//  Error+UserMessage.swift
//  MusicSearch
//
//  Created by Kiseok on 4/18/26.
//

import Foundation

extension Error {
	func userMessage(fallback: String) -> String {
		(self as? LocalizedError)?
			.errorDescription?
			.nilIfBlank ?? fallback
	}
}

private extension String {
	var nilIfBlank: String? {
		let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? nil : trimmed
	}
}
