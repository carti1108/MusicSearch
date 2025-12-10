//
//  WeatherDependency.swift
//  MusicSearch
//
//  Created by Kiseok on 12/9/25.
//

import Foundation
import NetworkLayer

protocol WeatherDependency: Dependency {
	var networkManager: NetworkRequesting { get }
	var locationManager: LocationManaging { get }
	var weatherAPIConfiguration: WeatherAPIConfiguration { get }
}

