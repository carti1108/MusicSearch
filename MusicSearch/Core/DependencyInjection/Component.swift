//
//  Component.swift
//  MusicSearch
//
//  Created by Kiseok on 12/10/25.
//

protocol Component {
	associatedtype DependencyType: Dependency

	init(dependency: DependencyType)
}
