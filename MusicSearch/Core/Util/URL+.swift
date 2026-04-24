//
//  URL+.swift
//  MusicSearch
//
//  Created by Kiseok on 12/12/25.
//

import Foundation

extension URL {
	var forcedHTTPS: URL {
		guard self.scheme == "http",
			  var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return self
		}
		components.scheme = "https"
		return components.url ?? self
	}
}
