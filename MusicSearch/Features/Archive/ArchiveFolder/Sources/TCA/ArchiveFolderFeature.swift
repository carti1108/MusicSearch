//
//  ArchiveFolderFeature.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ComposableArchitecture
import ArchiveDomain
import OSLog

@Reducer
public struct ArchiveFolderFeature: Sendable {

    @ObservableState
    public struct State: Equatable, Sendable {
        public var selectedTab: Int = 0
        public var releaseYearFolders: [FolderItem] = []
        public var listenYearFolders: [FolderItem] = []
        public var genreFolders: [FolderItem] = []
        public var ratingFolders: [FolderItem] = []

        public init() {}
    }

    @CasePathable
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case foldersLoaded(
            releaseYear: [FolderItem],
            listenYear: [FolderItem],
            genre: [FolderItem],
            rating: [FolderItem]
        )
        case folderTapped(FolderItem)
        case closeButtonTapped
        case delegate(DelegateAction)

        public enum DelegateAction: Equatable, Sendable {
            case didTapClose
            case didTapFolder(FolderItem)
        }
    }

    @Dependency(\.archiveRepository) var archiveRepository

	public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return .run { [archiveRepository] send in
                    do {
                        let tracks = try await archiveRepository.fetchArchivedTracks()

                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy"

                        let releaseGrouped = Dictionary(grouping: tracks.filter { $0.releaseDate != nil }, by: { track -> String in
                            if let date = track.releaseDate {
                                return formatter.string(from: date)
                            }
                            return ""
                        })
                        let releaseYearFolders = releaseGrouped.keys.sorted(by: >).map { year in
                            FolderItem(title: year + "년 발매", subtitle: "\(releaseGrouped[year]?.count ?? 0) 곡", type: .releaseYear(year: year))
                        }

                        let listenGrouped = Dictionary(grouping: tracks, by: { track -> String in
                            return formatter.string(from: track.listenDate)
                        })
                        let listenYearFolders = listenGrouped.keys.sorted(by: >).map { year in
                            FolderItem(title: year + "년 청취", subtitle: "\(listenGrouped[year]?.count ?? 0) 곡", type: .listenYear(year: year))
                        }

                        let groupedByGenre = Dictionary(grouping: tracks, by: { $0.genre })
                        let genreFolders = groupedByGenre.keys.sorted().map { genre in
                            FolderItem(title: genre, subtitle: "\(groupedByGenre[genre]?.count ?? 0) 곡", type: .genre(name: genre))
                        }

                        let groupedByRating = Dictionary(grouping: tracks, by: { Int($0.rating) })
                        let ratingFolders = groupedByRating.keys.sorted(by: >).map { rating in
                            let stars = String(repeating: "★", count: rating) + String(repeating: "☆", count: max(0, 5 - rating))
                            return FolderItem(title: stars, subtitle: "\(groupedByRating[rating]?.count ?? 0) 곡", type: .rating(value: rating))
                        }

                        await send(.foldersLoaded(
                            releaseYear: releaseYearFolders,
                            listenYear: listenYearFolders,
                            genre: genreFolders,
                            rating: ratingFolders
                        ))
                    } catch {
                        Logger(subsystem: "MusicSearch", category: "ArchiveFolderFeature").error("Failed to load folders: \(error.localizedDescription)")
                    }
                }

            case let .foldersLoaded(releaseYear, listenYear, genre, rating):
                state.releaseYearFolders = releaseYear
                state.listenYearFolders = listenYear
                state.genreFolders = genre
                state.ratingFolders = rating
                return .none

            case let .folderTapped(folder):
                return .send(.delegate(.didTapFolder(folder)))

            case .closeButtonTapped:
                return .send(.delegate(.didTapClose))

            case .delegate:
                return .none
            }
        }
    }
}
