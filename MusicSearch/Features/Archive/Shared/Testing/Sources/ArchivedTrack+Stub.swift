//
//  ArchivedTrack+Stub.swift
//  MusicSearch
//
//  Created by Kiseok on 7/18/26.
//

import Foundation
import ArchiveDomain

public extension ArchivedTrack {
    static func stub(
        id: UUID = UUID(),
        platformIDs: [String: String] = [:],
        coverImageData: Data? = nil,
        title: String = "Test Title",
        artist: String = "Test Artist",
        genres: [String] = ["Pop"],
        label: String = "",
        releaseDate: Date? = nil,
        listenDate: Date = Date(),
        rating: Double = 0,
        memo: String? = nil,
        albumTitle: String? = nil,
        distributor: String? = nil,
        albumType: String? = nil,
        isIntroGood: Bool = false,
        isGoodUntilMiddle: Bool = false,
        isGoodUntilEnd: Bool = false
    ) -> ArchivedTrack {
        ArchivedTrack(
            id: id,
            platformIDs: platformIDs,
            coverImageData: coverImageData,
            title: title,
            artist: artist,
            genres: genres,
            label: label,
            releaseDate: releaseDate,
            listenDate: listenDate,
            rating: rating,
            memo: memo,
            albumTitle: albumTitle,
            distributor: distributor,
            albumType: albumType,
            isIntroGood: isIntroGood,
            isGoodUntilMiddle: isGoodUntilMiddle,
            isGoodUntilEnd: isGoodUntilEnd
        )
    }
}
