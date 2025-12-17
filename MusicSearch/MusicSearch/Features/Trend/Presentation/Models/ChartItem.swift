//
//  ChartItem.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

struct ChartItem: Hashable {
	let id: String
	let rank: Int
	let title: String
	let subtitle: String
	let imageURL: URL?
	let type: ChartType
}


