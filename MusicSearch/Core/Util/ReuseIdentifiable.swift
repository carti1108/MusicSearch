//
//  ReuseIdentifiable.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

public protocol ReuseIdentifiable {
	static var reuseIdentifier: String { get }
}

public extension ReuseIdentifiable {
	static var reuseIdentifier: String {
		return String(describing: self)
	}
}
