//
//  Artist.swift
//  MusicSearch
//
//  Created by Kiseok on 12/7/25.
//

import Foundation

public struct Artist: Identifiable, Equatable, Hashable, Sendable {

	public let id: String
	public let name: String
	public let imageURL: URL?
	public let listeners: String?
	public let tags: [String]
	public let bio: String?

	public init(
		id: String = UUID().uuidString,
		name: String,
		imageURL: URL?,
		listeners: String? = nil,
		tags: [String] = [],
		bio: String? = nil
	) {
		self.id = id
		self.name = name
		self.imageURL = imageURL
		self.listeners = listeners
		self.tags = tags
		self.bio = bio
	}
}
