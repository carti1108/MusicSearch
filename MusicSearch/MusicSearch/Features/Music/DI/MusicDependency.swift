//
//  MusicDependency.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation
import NetworkLayer

protocol MusicDependency: Dependency {
	var networkManager: NetworkRequesting { get }
}

