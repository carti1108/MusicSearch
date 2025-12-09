//
//  ReuseIdentifiable.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

protocol ReuseIdentifiable {
	static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
	static var reuseIdentifier: String {
		return String(describing: self)
	}
}
