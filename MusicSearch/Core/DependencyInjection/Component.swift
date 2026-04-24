//
//  Component.swift
//  MusicSearch
//
//  Created by Kiseok on 12/10/25.
//

@MainActor
protocol Component {
	associatedtype DependencyType: Dependency

	init(dependency: DependencyType)
}
