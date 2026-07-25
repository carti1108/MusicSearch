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

@Reducer
public struct ArchiveFolderDetailFeature: Sendable {

    public enum ExportState: Equatable, Sendable {
        case idle
        case exporting(progress: ExportProgress)
        case completed(successCount: Int, failedCount: Int)
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public var folderItem: FolderItem
        public var title: String
        public var folders: [FolderItem]?
        public var tracks: [ArchivedTrack]?
        public var exportState: ExportState = .idle
        @Presents public var alert: AlertState<Action.Alert>?

        public init(folderItem: FolderItem) {
            self.folderItem = folderItem
            self.title = folderItem.title
        }
    }

    @CasePathable
    public enum Action: Sendable {
        case onAppear
        case loadDataResponse(folders: [FolderItem]?, tracks: [ArchivedTrack]?)
        case folderTapped(FolderItem)
        case trackTapped(ArchivedTrack)
        case closeButtonTapped
        case exportButtonTapped
        case loginPromptTapped
        case exportProgress(ExportProgress)
        case exportCompleted(successCount: Int, failedCount: Int)
        case alert(PresentationAction<Alert>)
        case delegate(DelegateAction)

        public enum Alert: Equatable, Sendable {
            case confirmLogin
            case exportResultAcknowledge
        }

        public enum DelegateAction: Equatable, Sendable {
            case didTapClose
            case didTapFolder(FolderItem)
            case didTapTrack(ArchivedTrack)
        }
    }

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
                        let contents = try await archiveRepository.fetchFolderContents(for: folderItem)
                        await send(.loadDataResponse(folders: contents.folders, tracks: contents.tracks))
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
                state.alert = AlertState { TextState("내보내기 완료") } actions: {
                    ButtonState(action: .exportResultAcknowledge) {
                        TextState("확인")
                    }
                } message: {
                    TextState("성공: \(success)곡, 실패: \(failed)곡")
                }
                return .none

            case .alert(.presented(.confirmLogin)):
                return .send(.loginPromptTapped)
                
            case .alert(.presented(.exportResultAcknowledge)):
                state.exportState = .idle
                return .none

            case .alert:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
