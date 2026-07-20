//
//  PredefinedGenre.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation

public enum PredefinedGenre: String, CaseIterable, Identifiable {
    case pop = "Pop"
    case rock = "Rock"
    case jazz = "Jazz"
    case classical = "Classical"
    case hiphop = "Hip-Hop"
    case rnb = "R&B"
    case electronic = "Electronic"
    case indie = "Indie"
    case kpop = "K-Pop"
    case jpop = "J-Pop"
    case citypop = "City Pop"
    case acoustic = "Acoustic"
    case ambient = "Ambient"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .pop: return "star.fill"
        case .rock: return "guitars.fill"
        case .jazz: return "saxophone.fill"
        case .classical: return "pianokeys"
        case .hiphop: return "mic.fill"
        case .rnb: return "music.mic"
        case .electronic: return "waveform"
        case .indie: return "leaf.fill"
        case .kpop: return "sparkles"
        case .jpop: return "music.note.list"
        case .citypop: return "building.2.fill"
        case .acoustic: return "guitars"
        case .ambient: return "cloud.fill"
        }
    }
}
