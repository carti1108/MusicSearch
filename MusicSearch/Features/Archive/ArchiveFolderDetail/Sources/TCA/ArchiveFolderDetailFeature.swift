//
//  ArchiveFolderDetailFeature.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ComposableArchitecture
import ArchiveDomain
import MSDomain
import OSLog
import FeatureArchiveFolderDetailInterface

@Reducer
public struct ArchiveFolderDetailFeature {

    public typealias State = ArchiveFolderDetailState
    public typealias Action = ArchiveFolderDetailAction

    private enum CancelID {
        case export
    }

    @Dependency(\.archiveRepository) var archiveRepository
    @Dependency(\.exportPlaylistUseCase) var exportPlaylistUseCase
    @Dependency(\.getMusicAccessTokenUseCase) var getMusicAccessTokenUseCase
    @Dependency(\.authorizeMusicUseCase) var authorizeMusicUseCase

	public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [folderItem = state.folderItem] send in
                    do {
                        let allTracks = try await archiveRepository.fetchArchivedTracks()
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
                            filteredTracks = allTracks.filter { $0.genre == name }
                        case .rating(let value):
                            filteredTracks = allTracks.filter { Int($0.rating) == value }
                        case .custom:
                            filteredTracks = allTracks
                        }

                        await send(.loadDataResponse(folders: isMonthGroup ? foldersToDisplay : nil, tracks: isMonthGroup ? nil : filteredTracks))
                    } catch {
                        Logger(subsystem: "MusicSearch", category: "ArchiveFolderDetailFeature").error("Failed to fetch folder tracks: \(error.localizedDescription)")
                    }
                }

            case let .loadDataResponse(folders, tracks):
                state.folders = folders
                state.tracks = tracks
                return .none

            case let .folderTapped(folder):
                return .send(.delegate(.didTapFolder(folder)))

            case let .trackTapped(track):
                return .send(.delegate(.didTapTrack(track)))

            case .closeButtonTapped:
                return .merge(
                    .cancel(id: CancelID.export),
                    .send(.delegate(.didTapClose))
                )

            case .exportButtonTapped:
                guard let tracks = state.tracks, !tracks.isEmpty else { return .none }
                if getMusicAccessTokenUseCase.execute() == nil {
                    state.alert = AlertState {
                        TextState("Spotify 연동 필요")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("취소")
                        }
                        ButtonState(action: .confirmLogin) {
                            TextState("로그인")
                        }
                    } message: {
                        TextState("플레이리스트를 내보내려면 Spotify 로그인이 필요합니다.")
                    }
                    return .none
                } else {
                    return .run { [title = state.title] send in
                        let playlistName = "MusicSearch Archive - \(title)"
                        for await progress in exportPlaylistUseCase.execute(tracks: tracks, playlistName: playlistName) {
                            await send(.exportProgress(progress))
                            if progress.isComplete {
                                await send(.exportCompleted(successCount: progress.currentCount - progress.failedTracks.count, failedCount: progress.failedTracks.count))
                            }
                        }
                    }
                    .cancellable(id: CancelID.export)
                }

            case .loginPromptTapped:
                return .run { send in
                    do {
                        try await authorizeMusicUseCase.execute()
                        await send(.exportButtonTapped)
                    } catch {
                        Logger(subsystem: "MusicSearch", category: "ArchiveFolderDetailFeature").error("Spotify authorization failed: \(error.localizedDescription)")
                    }
                }

            case let .exportProgress(progress):
                state.exportState = .exporting(progress: progress)
                return .none

            case let .exportCompleted(success, failed):
                state.exportState = .completed(successCount: success, failedCount: failed)
                return .none

            case .alert(.presented(.confirmLogin)):
                return .send(.loginPromptTapped)

            case .alert:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
