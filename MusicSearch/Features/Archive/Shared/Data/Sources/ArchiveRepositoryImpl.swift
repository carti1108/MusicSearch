//
//  ArchiveRepositoryImpl.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import SwiftData
import ArchiveDomain

@ModelActor
public actor ArchiveRepositoryImpl: ArchiveRepository {

	public func fetchArchivedTracks() throws -> [ArchivedTrack] {
		let descriptor = FetchDescriptor<SDArchivedTrack>(sortBy: [SortDescriptor(\.listenDate, order: .reverse)])
		let tracks = try modelContext.fetch(descriptor)
		return tracks.map { $0.toDomain() }
	}

	public func fetchFolderContents(for folderItem: FolderItem) throws -> FolderContents {
		let allTracks = try fetchArchivedTracks()
		let formatter = DateFormatter()

		var filteredTracks: [ArchivedTrack] = []
		var isMonthGroup = false
		var foldersToDisplay: [FolderItem]? = nil

		switch folderItem.type {
		case .releaseYear(let year):
			isMonthGroup = true
			formatter.dateFormat = "yyyy"
			filteredTracks = allTracks.filter { track in
				if let date = track.releaseDate {
					return formatter.string(from: date) == year
				}
				return false
			}

			formatter.dateFormat = "MM"
			let grouped = Dictionary(grouping: filteredTracks, by: { track -> String in
				if let date = track.releaseDate { return formatter.string(from: date) }
				return ""
			})
			foldersToDisplay = grouped.keys.filter { !$0.isEmpty }.sorted(by: <).map { month in
				FolderItem(title: month + "월", subtitle: "\(grouped[month]?.count ?? 0) 곡", type: .releaseMonth(year: year, month: month))
			}

		case .listenYear(let year):
			isMonthGroup = true
			formatter.dateFormat = "yyyy"
			filteredTracks = allTracks.filter { track in
				return formatter.string(from: track.listenDate) == year
			}

			formatter.dateFormat = "MM"
			let grouped = Dictionary(grouping: filteredTracks, by: { track -> String in
				return formatter.string(from: track.listenDate)
			})
			foldersToDisplay = grouped.keys.sorted(by: <).map { month in
				FolderItem(title: month + "월", subtitle: "\(grouped[month]?.count ?? 0) 곡", type: .listenMonth(year: year, month: month))
			}

		case .releaseMonth(let year, let month):
			isMonthGroup = true
			formatter.dateFormat = "yyyy-MM"
			filteredTracks = allTracks.filter { track in
				if let date = track.releaseDate {
					return formatter.string(from: date) == "\(year)-\(month)"
				}
				return false
			}

			let calendar = Calendar.current
			let grouped = Dictionary(grouping: filteredTracks, by: { track -> Int in
				if let date = track.releaseDate { return calendar.component(.weekOfMonth, from: date) }
				return 0
			})
			foldersToDisplay = grouped.keys.filter { $0 > 0 }.sorted(by: <).map { week in
				FolderItem(title: "\(week)주차", subtitle: "\(grouped[week]?.count ?? 0) 곡", type: .releaseWeek(year: year, month: month, week: "\(week)"))
			}

		case .listenMonth(let year, let month):
			isMonthGroup = true
			formatter.dateFormat = "yyyy-MM"
			filteredTracks = allTracks.filter { track in
				return formatter.string(from: track.listenDate) == "\(year)-\(month)"
			}

			let calendar = Calendar.current
			let grouped = Dictionary(grouping: filteredTracks, by: { track -> Int in
				return calendar.component(.weekOfMonth, from: track.listenDate)
			})
			foldersToDisplay = grouped.keys.sorted(by: <).map { week in
				FolderItem(title: "\(week)주차", subtitle: "\(grouped[week]?.count ?? 0) 곡", type: .listenWeek(year: year, month: month, week: "\(week)"))
			}

		case .releaseWeek(let year, let month, let week):
			formatter.dateFormat = "yyyy-MM"
			let calendar = Calendar.current
			filteredTracks = allTracks.filter { track in
				if let date = track.releaseDate {
					return formatter.string(from: date) == "\(year)-\(month)" && "\(calendar.component(.weekOfMonth, from: date))" == week
				}
				return false
			}

		case .listenWeek(let year, let month, let week):
			formatter.dateFormat = "yyyy-MM"
			let calendar = Calendar.current
			filteredTracks = allTracks.filter { track in
				return formatter.string(from: track.listenDate) == "\(year)-\(month)" && "\(calendar.component(.weekOfMonth, from: track.listenDate))" == week
			}
		case .genre(let name):
			filteredTracks = allTracks.filter { $0.genres.contains(name) }
		case .rating(let value):
			filteredTracks = allTracks.filter { Int($0.rating) == value }
		case .custom:
			filteredTracks = allTracks
		}

		return FolderContents(folders: isMonthGroup ? foldersToDisplay : nil, tracks: isMonthGroup ? nil : filteredTracks)
	}

	public func addArchivedTrack(_ track: ArchivedTrack) throws {
		let sdTrack = SDArchivedTrack(from: track)
		modelContext.insert(sdTrack)
		try modelContext.save()
	}

	public func updateArchivedTrack(_ track: ArchivedTrack) throws {
		let id = track.id
		let descriptor = FetchDescriptor<SDArchivedTrack>(predicate: #Predicate { $0.id == id })
		if let existingTrack = try modelContext.fetch(descriptor).first {
			existingTrack.platformIDs = track.platformIDs
			existingTrack.coverImageData = track.coverImageData
			existingTrack.title = track.title
			existingTrack.artist = track.artist
			existingTrack.genres = track.genres
			existingTrack.label = track.label
			existingTrack.releaseDate = track.releaseDate
			existingTrack.listenDate = track.listenDate
			existingTrack.rating = track.rating
			existingTrack.memo = track.memo
			existingTrack.albumTitle = track.albumTitle
			existingTrack.distributor = track.distributor
			existingTrack.albumType = track.albumType
			existingTrack.isIntroGood = track.isIntroGood
			existingTrack.isGoodUntilMiddle = track.isGoodUntilMiddle
			existingTrack.isGoodUntilEnd = track.isGoodUntilEnd

			try modelContext.save()
		} else {
			try addArchivedTrack(track)
		}
	}

	public func deleteArchivedTrack(id: UUID) throws {
		let descriptor = FetchDescriptor<SDArchivedTrack>(predicate: #Predicate { $0.id == id })
		if let trackToDelete = try modelContext.fetch(descriptor).first {
			modelContext.delete(trackToDelete)
			try modelContext.save()
		}
	}

	public func fetchAllGenres() throws -> [String] {
		let tracks = try fetchArchivedTracks()
		var genreSet = Set<String>()
		for track in tracks {
			for genre in track.genres {
				genreSet.insert(genre)
			}
		}
		return Array(genreSet).sorted()
	}
}
