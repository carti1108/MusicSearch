//
//  AddArchiveFeature.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ComposableArchitecture
import ArchiveDomain
import TrackSearchDomain
import MSDomain
import OSLog
import FeatureArchiveTrackSearch

@Reducer
public struct AddArchiveFeature: Sendable {

    public enum Alert: Equatable, Sendable {}

    @ObservableState
    public struct State: Equatable, Sendable {
        public var availableGenres: [String] = []
        public var selectedTrack: Track? = nil

        public var title: String = ""
        public var artist: String = ""
        public var genres: [String] = []
        public var genreInputText: String = ""
        public var recommendedGenres: [String] = []
        public var label: String = ""
        public var albumTitle: String = ""
        public var distributor: String = ""
        public var albumType: String = "정규"
        public var isIntroGood: Bool = false
        public var isGoodUntilMiddle: Bool = false
        public var isGoodUntilEnd: Bool = false
        public var rating: Double = 3.0
        public var memo: String = ""

        public var releaseDate: Date = Date()
        public var hasReleaseDate: Bool = false
        public var listenDate: Date = Date()

        public var coverImageData: Data?
        public var isGenreExpanded: Bool = false
        public var platformIDs: [String: String] = [:]

        public var editTrackId: UUID?
        public var isEditMode: Bool = false

        @Presents public var trackSearch: ArchiveTrackSearchFeature.State?
        @Presents public var alert: AlertState<Alert>?

        public init(editTrack: ArchivedTrack? = nil) {
            if let track = editTrack {
                self.editTrackId = track.id
                self.isEditMode = true
                self.title = track.title
                self.artist = track.artist
                self.genres = track.genres
                self.label = track.label
                self.albumTitle = track.albumTitle ?? ""
                self.distributor = track.distributor ?? ""
                self.albumType = track.albumType ?? "정규"
                self.isIntroGood = track.isIntroGood
                self.isGoodUntilMiddle = track.isGoodUntilMiddle
                self.isGoodUntilEnd = track.isGoodUntilEnd
                self.rating = track.rating
                self.memo = track.memo ?? ""
                if let date = track.releaseDate {
                    self.hasReleaseDate = true
                    self.releaseDate = date
                }
                self.listenDate = track.listenDate
                self.coverImageData = track.coverImageData
                self.platformIDs = track.platformIDs
            }
        }
    }

    @CasePathable
    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case closeButtonTapped
        case searchButtonTapped
        case saveButtonTapped
        case genreInputTextChanged(String)
        case addGenre(String)
        case removeGenre(String)
        case trackSelected(Track)
        case coverImageLoaded(Data?)
        case setCoverImageData(Data?)
        case genresLoaded(TaskResult<[String]>)
        case trackSaved(TaskResult<Void>)
        case trackSearch(PresentationAction<ArchiveTrackSearchFeature.Action>)
        case alert(PresentationAction<Alert>)
        case delegate(DelegateAction)

        @CasePathable
        public enum DelegateAction: Equatable, Sendable {
            case didCloseAddArchive
        }
    }

	@Dependency(\.archiveRepository) var archiveRepository
	@Dependency(\.searchTracksUseCase) var searchTracksUseCase
	@Dependency(\.imageClient) var imageClient

	public init() {}

	public var body: some ReducerOf<Self> {
		BindingReducer()

		Reduce { state, action in
			switch action {
			case .binding:
				return .none

			case .onAppear:
				return .run { send in
					await send(.genresLoaded(TaskResult {
						let customGenres = try await archiveRepository.fetchAllGenres()
						let predefined = PredefinedGenre.allCases.map { $0.rawValue }

						var combined = predefined
						for custom in customGenres {
							if !combined.contains(custom) {
								combined.append(custom)
							}
						}
						return combined
					}))
				}

			case let .genresLoaded(.success(genres)):
				state.availableGenres = genres
				return .none

			case .genresLoaded(.failure):
				return .none

			case .closeButtonTapped:
				return .send(.delegate(.didCloseAddArchive))

			case .searchButtonTapped:
				state.trackSearch = ArchiveTrackSearchFeature.State()
				return .none

            case let .genreInputTextChanged(text):
                state.genreInputText = text
                if text.isEmpty {
                    state.recommendedGenres = []
                } else {
                    state.recommendedGenres = state.availableGenres.filter {
                        $0.lowercased().contains(text.lowercased()) && !state.genres.contains($0)
                    }
                }
                return .none

            case let .addGenre(genre):
                let trimmed = genre.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty && !state.genres.contains(trimmed) {
                    state.genres.append(trimmed)
                }
                state.genreInputText = ""
                state.recommendedGenres = []
                return .none

            case let .removeGenre(genre):
                state.genres.removeAll { $0 == genre }
                return .none

			case let .setCoverImageData(data):
				state.coverImageData = data
				return .none

			case let .trackSelected(track):
				state.selectedTrack = track
				state.title = track.title
				state.artist = track.artist
				state.albumTitle = track.albumTitle ?? ""

				if let type = track.albumType {
					if type.lowercased() == "single" {
						state.albumType = "싱글"
					} else if type.lowercased() == "ep" || type.lowercased() == "ep/single" {
						state.albumType = "EP"
					} else {
						state.albumType = "정규"
					}
				}

				if let date = track.releaseDate {
					state.hasReleaseDate = true
					state.releaseDate = date
				}

				state.platformIDs["spotify"] = track.id

				if let imageURL = track.imageURL {
					return .run { send in
						do {
							let data = try await imageClient.fetch(imageURL)
							await send(.coverImageLoaded(data))
						} catch {
							Logger(subsystem: "MusicSearch", category: "AddArchiveFeature").error("Fetch cover image failed: \(error.localizedDescription)")
							await send(.coverImageLoaded(nil))
						}
					}
				}
				return .none

			case let .coverImageLoaded(data):
				state.coverImageData = data
				return .none

			case .saveButtonTapped:
				if state.genres.isEmpty {
					state.alert = AlertState { TextState("입력 오류") } message: { TextState("최소 1개의 장르를 입력해주세요.") }
					return .none
				}
				if state.memo.count > 500 {
					state.alert = AlertState { TextState("입력 오류") } message: { TextState("메모는 500자를 초과할 수 없습니다.") }
					return .none
				}
				if let imageData = state.coverImageData, imageData.count > 5 * 1024 * 1024 {
					state.alert = AlertState { TextState("이미지 오류") } message: { TextState("이미지 크기는 5MB를 초과할 수 없습니다.") }
					return .none
				}

				let track = ArchivedTrack(
					id: state.editTrackId ?? UUID(),
					platformIDs: state.platformIDs,
					coverImageData: state.coverImageData,
					title: state.title,
					artist: state.artist,
					genres: state.genres,
					label: state.label,
					releaseDate: state.hasReleaseDate ? state.releaseDate : nil,
					listenDate: state.listenDate,
					rating: state.rating,
					memo: state.memo,
					albumTitle: state.albumTitle,
					distributor: state.distributor,
					albumType: state.albumType,
					isIntroGood: state.isIntroGood,
					isGoodUntilMiddle: state.isGoodUntilMiddle,
					isGoodUntilEnd: state.isGoodUntilEnd
				)
				return .run { [isEditMode = state.isEditMode] send in
					await send(.trackSaved(TaskResult {
						if isEditMode {
							try await archiveRepository.updateArchivedTrack(track)
						} else {
							try await archiveRepository.addArchivedTrack(track)
						}
					}))
				}

			case .trackSaved(.success):
				return .send(.delegate(.didCloseAddArchive))

			case let .trackSaved(.failure(error)):
				state.alert = AlertState { TextState("저장 실패") } message: { TextState("저장 중 문제가 발생했습니다: \(error.localizedDescription)") }
				return .none

			case .alert:
				return .none

			case let .trackSearch(.presented(.delegate(.trackSelected(track)))):
				state.trackSearch = nil
				return .send(.trackSelected(track))

			case .trackSearch(.presented(.closeButtonTapped)):
				state.trackSearch = nil
				return .none

			case .trackSearch:
				return .none

			case .delegate:
				return .none
			}
		}
		.ifLet(\.$alert, action: \.alert)
		.ifLet(\.$trackSearch, action: \.trackSearch) {
			ArchiveTrackSearchFeature()
		}
	}
}
